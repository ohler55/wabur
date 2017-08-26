
module WAB

  module Impl

    # HTTP request info. This is a small subset of the Net::HTTPRequest and is
    # not used for sending.
    class Request
      attr_accessor :method
      attr_accessor :path
      attr_accessor :query
      attr_accessor :body
      attr_accessor :header

      def initialize(sock)
        @path = []
        @query = {}
        @header = {}

        line = sock.gets
        @method, url, rest = line.split(' ');
        url = URI(url)
        @path = URI.unescape(url.path).split('/')[1..-1]
        unless url.query.nil?
          url.query.split('&').each { |opt|
            key, value = opt.split('=')
            query[URI.unescape(key)] = URI.unescape(value)
          }
        end
        loop do
          line = sock.gets
          line.chomp!
          break if 0 == line.length
          key, value = line.split(':', 2)
          @header[key.downcase] = value.strip
        end
        cnt = @header['content-length']
        unless cnt.nil? || 0 == cnt.length
          @body = sock.read(cnt.to_i)
        end
      end

    end # Request
  end # Impl
end # WAB
