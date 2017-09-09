
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
        @timeout_thread = nil
        @proc_threads = []
      end

      def start()
        @tcnt.times {
          @proc_threads << Thread.new {
            while true
              begin
                break unless process_msg(@queue.pop)
              rescue Exception => e
                $stderr.puts %|*-*-* #{e.class}: #{e.message}\n#{e.backtrace.join("\n  ")}|
              end
            end
          }
        }
        @timeout_thread = Thread.new { timeout_check() }

        Oj.load($stdin, mode: :wab, symbol_keys: true) { |msg|
          api = msg[:api]
          @shell.info("=> controller #{Oj.dump(msg, mode: :wab)}") if @shell.info?
          case api
          when 1
            @queue.push(msg)
          when 4
            rid = msg[:rid]
            call = nil
            @lock.synchronize {
              call = @pending.delete(rid)
            }
            unless call.nil?
              call.result = msg[:body]
              call.thread.run
            end
          when -2, -3, -6, -15
            shutdown(msg)
            break
          when -9
            Thread.kill(@timeout_thread)
            @proc_threads.each { |t| Thread.kill(t) }
            Process.exit(0)
          else
            $stderr.puts "*-*-* Invalid api value (#{api}) in message."
          end
        }
      end

      def shutdown(msg)
        # TBD kill timeout thread
        Thread.kill(@timeout_thread)
        # tell processing threads to shutdown.
        @tcnt.times { @queue.push(msg) }
      end

      # Send request to the model portion of the system.
      #
      # tql:: the body of the message which should be JSON-TQL as a native Hash
      def request(tql, timeout)
        call = Call.new(timeout)
        @lock.synchronize {
          @last_rid += 1
          call.rid = @last_rid.to_s
          @pending[call.rid] = call
        }
        msg = {rid: call.rid, api: 3, body: tql}
        @shell.info("=> model: #{Oj.dump(msg, mode: :wab)}") if @shell.info?
        data = @shell.data(msg, true)
        # Send the message. Make sure to flush to assure it gets sent.
        $stdout.puts(data.json())
        $stdout.flush()

        # Wait for either the response to arrive or for a timeout. In both
        # cases #run should be called on the thread. Sleep is used instead of
        # stop to avoid a race condition where a response arrives before the
        # thread is stopped.
        sleep(0.1) while call.result.nil?
        call.result
      end

      def send_error(rid, msg, bt=nil)
        body = { code: -1, error: msg }
        body[:backtrace] = bt unless bt.nil?
        $stdout.puts(@shell.data({rid: rid, api: 2, body: body}).json)
        $stdout.flush
        true
      end

      # return false to exit loop
      def process_msg(native)
        # exit loop if an interrupt (api less than 0)
        return false if native[:api] < 0

        rid = native[:rid]
        body = native[:body]

        return send_error(rid, 'No body in request.') if body.nil?

        data = @shell.data(body, false)
        data.detect()
        controller = @shell.controller(data)
        return send_error(rid, 'No handler found.') if controller.nil?

        reply_body = nil
        op = body[:op]
        path = body[:path]
        query = body[:query]
        begin
          if 'NEW' == op && controller.respond_to?(:create)
            @shell.info("=> controller.create(#{path.join('/')}#{query}, #{Oj.dump(body[:content], mode: :wab)})") if @shell.info?
            reply_body = controller.create(path, query, data.get(:content))
          elsif 'GET' == op && controller.respond_to?(:read)
            @shell.info("=> controller.read(#{path.join('/')}#{query})") if @shell.info?
            reply_body = controller.read(path, query)
          elsif 'DEL' == op && controller.respond_to?(:delete)
            @shell.info("=> controller.delete(#{path.join('/')}#{query})") if @shell.info?
            reply_body = controller.delete(path, query)
          elsif 'MOD' == op && controller.respond_to?(:update)
            @shell.info("=> controller.update(#{path.join('/')}#{query}, #{Oj.dump(body[:content], mode: :wab)})") if @shell.info?
            reply_body = controller.update(path, query, data.get(:content))
          else
            reply_body = controller.handle(data)
          end
        rescue Exception => e
          return send_error(rid, "#{e.class}: #{e.message}", e.backtrace)
        end
        # If reply_body is nil then it is async.
        unless reply_body.nil?
          reply_body = reply_body.native if reply_body.is_a?(::WAB::Data)
          msg = {rid: rid, api: 2, body: reply_body}
          @shell.info("=> view: #{Oj.dump(msg, mode: :wab)}") if @shell.info?
          $stdout.puts(@shell.data(msg).json)
          $stdout.flush
        end
        true
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
              call.result = body
              call.thread.run
            end
          }
        end
      end

    end # Engine
  end # IO
end # WAB
