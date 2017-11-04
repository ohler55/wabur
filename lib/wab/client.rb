
require 'net/http'
require 'oj'

module WAB

  # A client for a WAB server. It is not specific to any particular
  # runner. The client allows direct access to the server data. It is just
  # another view implementation.
  class Client
    # Address of the WAB server.
    attr_accessor :server_address
    # The port the WAB serer is listening on.
    attr_accessor :server_port
    # Prefix to add to the URL path.
    attr_accessor :path_prefix
    # The URL path to execute TQL,
    attr_accessor :tql_path
    # The key for the type. The default is 'kind'.
    attr_accessor :type_key
    # If true the connection to the server is Keep-Alive.
    attr_accessor :keep_alive

    # Create a new Client for the server at +addr+ and +port+. The provided
    # options should match the attribute names and types.
    def initialize(addr, port, options={})
      @server_address = addr
      @server_port = port
      @path_prefix = options.fetch(:path_prefix, '/v1/')
      @tql_path = options.fetch(:tql_path, '/tql')
      @type_key = options.fetch(:type_key, 'kind')
      @keep_alive = !!options.fetch(:keep_alive, true)
      @http = nil
    end

    # Create a new data object. If a query is provided it is treated as a
    # check against an existing object with the same key/value pairs.
    #
    # On error an Exception will be raised.
    #
    # data:: the data to use as a new object.
    # kind:: the kind of the data. If nil the kind is taken from the data
    # query:: query parameters to match against existing instances. A match fails the insert.
    def create(data, kind=nil, query=nil)
      kind = data[@type_key] if kind.nil?
      send_request('PUT', kind, query, data)
    end

    # Return the objects according to the kind and query arguments. The
    # following patterns supported:
    #
    # * query is a ref [12345] looks for MyType with reference ID of 12345
    # * query is a Hash {name:fred,age:63} looks for all MyTypes with a name
    #                                      of 'fred' and an age of 63.
    #
    # kind:: the data type
    # query:: query parameters as a Hash.
    def read(kind, query=nil)
      send_request('GET', kind, query, nil)
    end
    
    # Replaces the object data for the identified object. The query can be a
    # reference to a specific object or a set of parameters to match.
    #
    # The return should be the identifiers for the object updated.
    #
    # On error an Exception should be raised.
    #
    # kind:: the data type
    # data:: the data to use as a new object.
    # query:: query parameters.
    def update(kind, data, query)
      raise ArgError.new('data') if data.nil?
      raise ArgError.new('query') if query.nil?
      send_request('POST', kind, query, data)
    end

    # Deletes the data for the identified object(s). The query can be a
    # reference to a specific object or a set of parameters to match.
    #
    # The return is the identifiers for the object updated.
    #
    # On error an Exception should be raised.
    #
    # kind:: the data type
    # query:: query parameters.
    def delete(kind, query=nil)
      send_request('DELETE', kind, query, nil)
    end

    # Request the server evaluate a TQL query.
    #
    # tql:: query to evaluate.
    def find(tql)
      raise ArgError.new('tql') if tql.nil?
      send_request('POST', 'tql', nil, tql)
    end
    
    private

    def connect
      @http ||= Net::HTTP.new(@server_address, @server_port)
    end

    def form_path(kind, query)
      return @tql_path if kind == 'tql'
      path = "#{@path_prefix}#{kind}"
      if query.is_a?(Hash)
        first = true
        query.each_pair { |k,v|
          if first
            path << '?'
            first = false
          else
            path << '&'
          end
          path << "#{k}=#{v}"
        }
      elsif !query.nil?
        path << '/'
        path << query.to_s
      end
      path
    end
    
    def send_request(method, kind, query, content)
      connect
      header = {'Connection' => (@keep_alive ? 'Keep-Alive' : 'Close') }
      unless content.nil?
        if content.is_a?(Data)
          content = content.json
        else
          content = Oj.dump(content, mode: :wab, indent: 0)
        end
        header['Content-Type'] = 'application/json'
        resp = @http.send_request(method, form_path(kind, query), content, header)
      else
        resp = @http.send_request(method, form_path(kind, query))
      end
      raise Error.new(resp.body) unless resp.is_a?(Net::HTTPOK)
      reply = Oj.load(resp.body, mode: :wab)
    end

  end # Client
end # WAB
