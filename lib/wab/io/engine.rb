
require 'wab'

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
          Thread.new {
            process_msg(@queue.pop)
          }
        }

        # TBD create timeout thread, sync on lock to check timeout in pending, sleep for .5

        Oj.strict_load($stdin, symbol_keys: true) { |msg|
          api = msg[:api]
          if 1 == api
            @queue.push(msg)
          elsif 4 == api
            rid = msg[:rid]
            call = nil
            @lock.synchronize {
              call = @pending.delete(rid)
            }
            unless call.nil?
              call.result = msg[:body]
              call.thread.run
            end
          else
            # TBD handle error
          end
        }
      end


      # Send request to the model portion of the system.
      #
      # tql:: the body of the message which should be JSON-TQL as a native Hash
      def request(tql)
        call = Call.new() # TBD make timeout seconds a parameter
        @lock.synchronize {
          @last_rid += 1
          call.rid = @last_rid.to_s
          @pending[call.rid] = call
        }
        data = @shell.data({ rid: call.rid, api: 3, body: tql }, true)
        # Send the message. Make sure to flush to assure it gets sent.
        $stdout.puts(data.json())
        $stdout.flush()
        
        # Wait for either the response to arrive or for a timeout. In both
        # cases #run should be called on the thread.
        Thread.stop
        call.result
      end

      def process_msg(native)
        rid = native[:rid]
        api = native[:api]
        body = native[:body]
        reply = @shell.data({rid: rid, api: 2})
        if body.nil?
          reply.set('body.code', -1)
          reply.set('body.error', 'No body in request.')
        else
          data = @shell.data(body, false)
          data.detect()
          controller = @shell.controller(data)
          if controller.nil?
            reply.set('body.code', -1)
            reply.set('body.error', 'No handler found.')
          else
            op = body[:op]
            begin
              if 'NEW' == op && controller.respond_to?(:create)
                reply.set('body', controller.create(body[:path], body[:query], data.get(:content)))
              elsif 'GET' == op && controller.respond_to?(:read)
                reply.set('body', controller.read(body[:path], body[:query]))
              elsif 'DEL' == op && controller.respond_to?(:delete)
                reply.set('body', controller.delete(body[:path], body[:query]))
              elsif 'MOD' == op && controller.respond_to?(:update)
                # Also used for TQL queries
                reply.set('body', controller.update(body[:path], body[:query], data.get(:content)))
              else
                reply.set('body', controller.handle(data))
              end
            rescue Exception => e
              reply.set('body.code', -1)
              reply.set('body.error', e.message)
              reply.set('body.backtrace', e.backtrace)
            end
          end
        end
        $stdout.puts(reply.json)
        $stdout.flush
      end

    end # Engine
  end # IO
end # WAB
