
require 'socket'
require 'uri'

require 'wab'
require 'wab/impl/request'

module WAB

  module Impl

    # The Server is used by the Shell to accept and respond to requests. It is
    # basically the HTTP listen loop for the Shell.
    class Server

      # Starts listening on the specified port for HTTP requests. It is a
      # simple single threaded listener. The initialize does not exit until
      # the loop is interupted.
      #
      # shell:: Shell that started the Server
      # port:: port to listen on
      # dir:: directory to load files from
      # pre:: path prefix for controller handling
      def initialize(shell, port, dir, pre)
        @shell = shell
        @dir = dir
        pre = pre.split('/')
        server = TCPServer.new('localhost', port)
        loop do
          sock = server.accept
          req = Request.new(sock)

          handle = true
          if pre.length <= req.path.length
            pre.each_index { |i|
              if pre[i] != req.path[i]
                handle = false
                break
              end
            }
          end
          if handle
            call_controller(sock, req)
          else
            send_file(sock, req.path)
          end

          sock.close
        end
      end

      def call_controller(sock, req)
        body = "controller for #{req.path}"
        sock.print("HTTP/1.1 200 OK\r\n" +
                   "Content-Type: text/plain\r\n" +
                   "Content-Length: #{body.length}\r\n" +
                   "Connection: close\r\n" +
                   "\r\n")
        sock.print(body)
      end

      def send_file(sock, path)
        body = "contents of #{File.join(path)}"
        sock.print("HTTP/1.1 200 OK\r\n" +
                   "Content-Type: text/plain\r\n" +
                   "Content-Length: #{body.length}\r\n" +
                   "Connection: close\r\n" +
                   "\r\n")
        sock.print(body)
      end

    end # Server
  end # Impl
end # WAB
