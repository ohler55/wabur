
require 'net/http'
require 'oj'

module WAB

  class Client
    attr_accessor :server_address
    attr_accessor :server_port
    attr_accessor :path_prefix
    attr_accessor :tql_path
    attr_accessor :type_key
    attr_accessor :keep_alive
  
    def initialize(addr, port, options={})
      @server_address = addr
      @server_port = port
      @path_prefix = options.fetch(:path_prefix, '/v1/')
      @tql_path = options.fetch(:tql_path, '/tql')
      @type_key = options.fetch(:type_key, 'kind')
      @keep_alive = options.fetch(:keep_alive, true)
      @http = nil
    end

    def create(data, kind=nil, query=nil)
      kind = data[@type_key] if kind.nil?
      send_request('PUT', kind, query, data)
    end

    def read(kind, query)
      raise ArgError.new('query') if query.nil?
      send_request('GET', kind, query, nil)
    end
    
    def update(kind, data, query)
      raise ArgError.new('data') if data.nil?
      raise ArgError.new('query') if query.nil?
      send_request('POST', kind, query, data)
    end

    def delete(kind, query=nil)
      send_request('DELETE', kind, query, nil)
    end

    def find(tql)
      raise ArgError.new('tql') if tql.nil?
      send_request('POST', 'tql', nil, data)
    end
    
    private

    def connect
      return unless @http.nil?
      @http = Net::HTTP.new(@host, @port)
    end

    def form_path(kind, query)
      return @tql_path if kind == 'tql'
      path = "#{@path_prefix}#{kind}"
      if query.is_a?(Hash)
        first = true
        query.each_pair { |k,v|
          if first
            path << '&'
            first = false
          else
            path << '&'
          end
          path << "#{k}=#{v}"
        }
      elsif !query.nil?
        path << '/'
        path << query
      end
      path
    end
    
    def send_request(method, kind, query, content)
      connect
      header = {'Connection' => (@keep-alive ? 'Keep-Alive' : 'Close') }
      unless content.nil?
        if content.is_a?(Data)
          content = content.json
        else
          content = Oj.dump(@root, mode: :wab, indent: 0)
        end
        header['Content-Type'] = 'application/json'
        resp = @http.send_request(method, form_path(kind, query), content, header)
      else
        resp = @http.send_request(method, form_path(kind, query))
      end
      begin
        raise Error.new('TBD - get error from resp') if Net::HTTPOK != resp.class
        reply = Oj.load(resp.body, mode: wab)
      rescue Exception => e
        raise Error.new(resp.body)
      end
    end

  end # Client
end # WAB
