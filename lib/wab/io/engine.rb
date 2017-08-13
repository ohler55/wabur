
require 'wab'
require 'oj'

module WAB

  module IO

    class Engine

      # Starts the engine by creating a listener on STDIN. Processing threads
      # are also created to handle the processing of requests.
      #
      # tcnt:: processing thread count
      def initialize(shell, tcnt)
        @shell = shell
        @last_rid = 0
        @pending = {}
        @lock = Thread::Mutex.new()
        @queue = Queue.new()
        tcnt = 1 if 0 >= tcnt
        @tcnt = tcnt
      end

      def start()
        @tcnt.times {
          Thread.new { process_msg(@queue.pop) }
        }
        Thread.new { timeout_check() }

        Oj.strict_load($stdin, symbol_keys: true) { |msg|
          api = msg[:api]
          $stderr.puts "=> controller #{Oj.dump(msg, mode: :strict)}" if @shell.verbose
          if 1 == api
            @queue.push(msg)
          elsif 4 == api
            rid = msg[:rid]
            call = nil
            @lock.synchronize {
              call = @pending.delete(rid)
            }
            unless call.nil?
              if call.handler.nil?
                call.result = msg[:body]
                call.thread.run
              else
                call.handler.on_result(msg[:body])
              end
            end
          else
            $stderr.puts "*-*-* Invalid api value (#{api}) in message."
          end
        }
      end

      # Send request to the model portion of the system.
      #
      # tql:: the body of the message which should be JSON-TQL as a native Hash
      def request(tql, handler, timeout)
        call = Call.new(handler, tql[:rid], timeout)
        @lock.synchronize {
          @last_rid += 1
          call.rid = @last_rid.to_s
          @pending[call.rid] = call
        }
        msg = {rid: call.rid, api: 3, body: tql}
        $stderr.puts "=> model: #{Oj.dump(msg, mode: :strict)}" if @shell.verbose
        data = @shell.data(msg, true)
        # Send the message. Make sure to flush to assure it gets sent.
        $stdout.puts(data.json())
        $stdout.flush()

        if handler.nil?
          # Wait for either the response to arrive or for a timeout. In both
          # cases #run should be called on the thread.
          Thread.stop
          call.result
        else
          nil
        end
      end

      def send_error(rid, msg, bt=nil)
        body = { code: -1, error: msg }
        body[:backtrace] = bt unless bt.nil?
        body[:rid] = rid unless rid.nil?
        $stdout.puts(@shell.data({rid: rid, api: 2, body: body}).json)
        $stdout.flush
        nil
      end

      def process_msg(native)
        rid = native[:rid]
        body = native[:body]

        return send_error(rid, 'No body in request.') if body.nil?

        data = @shell.data(body, false)
        data.detect()
        controller = @shell.controller(data)
        return send_error(rid, 'No handler found.') if controller.nil?

        reply_body = nil
        op = body[:op]
        begin
          if 'NEW' == op && controller.respond_to?(:create)
            reply_body = controller.create(body[:path], body[:query], data.get(:content), rid)
          elsif 'GET' == op && controller.respond_to?(:read)
            reply_body = controller.read(body[:path], body[:query], rid)
          elsif 'DEL' == op && controller.respond_to?(:delete)
            reply_body = controller.delete(body[:path], body[:query], rid)
          elsif 'MOD' == op && controller.respond_to?(:update)
            reply_body = controller.update(body[:path], body[:query], data.get(:content), rid)
          else
            reply_body = controller.handle(data)
          end
        rescue Exception => e
          return send_error(rid, e.message, e.backtrace)
        end
        # If reply_body is nil then it is async.
        unless reply_body.nil?
          reply_body = reply_body.native if reply_body.is_a?(::WAB::Data)
          msg = {rid: rid, api: 2, body: reply_body}
          $stderr.puts "=> view: #{Oj.dump(msg, mode: :strict)}" if @shell.verbose
          $stdout.puts(@shell.data(msg).json)
          $stdout.flush
        end
      end

      def timeout_check()
        while true
          sleep(0.5)
          timed_out = []
          now = Time.now
          @lock.synchronize {
            @pending.delete_if { |rid,call|
              if call.giveup <= now
                timed_out << call
                true
              else
                false
              end
            }
          }
          timed_out.each { |call|
            body = { code: -1, error: "Timed out waiting for #{call.rid}." }
            unless call.nil?
              if call.handler.nil?
                call.result = body
                call.thread.run
              else
                body[:rid] = call.qrid
                call.handler.on_result(body)
              end
            end
          }
        end
      end

    end # Engine
  end # IO
end # WAB
