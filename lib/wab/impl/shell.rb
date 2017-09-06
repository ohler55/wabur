
require 'webrick'

require 'wab'
require 'wab/impl/model'

module WAB
  module Impl

    # Handler for requests that fall under the path assigned to the
    # Controller. This is used only with the ::WAB::Impl::Shell.
    class Handler < WEBrick::HTTPServlet::AbstractServlet

      def initialize(server, shell)
        super(server)
        @shell = shell
      end

      def do_GET(req, res)
        begin
          ctrl, path, query, _ =  extract_req(req)
          @shell.logger.info("controller.read(#{path.join('/')}#{query})") if @shell.logger.info?
          result = ctrl.read(path, query)
          send_result(ctrl.read(path, query), res)
        rescue Exception => e
          send_error(e, res)
        end
      end

      def do_PUT(req, res)
        begin
          ctrl, path, query, body =  extract_req(req)
          @shell.logger.info("controller.create(#{path.join('/')}#{query}, #{body.json})") if @shell.logger.info?
          send_result(ctrl.create(path, query, body), res)
        rescue Exception => e
          send_error(e, res)
        end
      end

      def do_POST(req, res)
        begin
          ctrl, path, query, body =  extract_req(req)
          @shell.logger.info("controller.update(#{path.join('/')}#{query}, #{body.json})") if @shell.logger.info?
          send_result(ctrl.update(path, query, body), res)
        rescue Exception => e
          send_error(e, res)
        end
      end

      def do_DELETE(req, res)
        begin
          ctrl, path, query, _ =  extract_req(req)
          @shell.logger.info("controller.delete(#{path.join('/')}#{query})") if @shell.logger.info?
          send_result(ctrl.delete(path, query), res)
        rescue Exception => e
          send_error(e, res)
        end
      end

      private

      # Pulls and converts the request path, query, and body. Also returns the
      # controller.
      def extract_req(req)
        path = req.path.split('/')[1..-1]
        query = {}
        req.query.each { |k,v| query[k.to_sym] = v }
        if req.body.nil?
          body = nil
        else
          body = Oj.strict_load(req.body, symbol_keys: true)
          body = Data.new(body, false)
          body.detect()
        end
        [@shell.path_controller(path), path, query, body]
      end
      
      # Sends the results from a controller request.
      def send_result(result, res)
        result = @shell.data(result) unless result.is_a?(::WAB::Data)
        res.status = 200
        res['Content-Type'] = 'application/json'
        @shell.logger.debug("Reply: #{result.json}") if @shell.logger.debug?
        res.body = result.json
      end

      # Sends an error from a rescued call.
      def send_error(e, res)
        res.status = 500
        res['Content-Type'] = 'application/json'
        body = { code: -1, error: "#{e.class}: #{e.message}" }
        body[:backtrace] = e.backtrace
        res.body = @shell.data(body).json
        @shell.logger.warn(%|*-*-* #{e.class}: #{e.message}\n      #{e.backtrace.join("\n      ")}|)
      end

    end # Handler

    # The shell for reference Ruby implementation.
    class Shell
      include WAB::ShellLogger

      attr_accessor :verbose

      # Returns the path where a data type is located. The default is 'kind'.
      attr_reader :type_key
      attr_reader :path_pos

      # Sets up the shell with the supplied configuration data.
      #
      # cfg:: configuration Hash
      def initialize(cfg)
        @controllers = {}
        pre_path = cfg['handler.path'] || '/v1'
        @path_pos = pre_path.split('/').length - 1
        @type_key = cfg['type_key'] || 'kind'
        @http_dir = File.expand_path(cfg['http.dir'] || '.')
        if cfg.has_key?('http.port')
          @http_port = cfg['http.port'].to_i
        else
          @http_port = 6363
        end
        if cfg.has_key?('verbose')
          v = cfg['verbose']
          if v.is_a?(String)
            v = v.downcase
            if 'true' == v
              @verbose = true
            elsif 'false' == v
              @verbose = false
            end
          elsif v == true || v == false
            @verbose = v
          end
        end
        @model = Model.new(cfg['dir'])
      end

      # Start listening. This should be called after registering Controllers
      # with the Shell.
      def start()
        server = WEBrick::HTTPServer.new(Port: @http_port, DocumentRoot: @http_dir)

        server.mount('/v1', ::WAB::Impl::Handler, self)

        trap 'INT' do server.shutdown end
        server.start
      end

      # Register a controller for a named type.
      #
      # If a request is received for an unregistered type the default controller
      # will be used. The default controller is registered with a +nil+ key.
      #
      # type:: type name
      # controller:: Controller instance for handling requests for the identified +type+
      def register_controller(type, controller)
        controller.shell = self
        @controllers[type] = controller
      end

      # Returns the controller associated with the type key found in the
      # data. If a controller has not be registered under that key the default
      # controller is returned if there is one.
      #
      # data:: data to extract the type from for lookup in the controllers
      def controller(data)
        path = data.get(:path)
        path = path.native if path.is_a?(::WAB::Data)
        if path.nil? || path.length <= @path_pos
          content = data.get(:content)
          return @controllers[content.get(@type_key)] || @controllers[nil] unless content.nil?
        else
          return path_controllers(path)
        end
        @controllers[nil]
      end

      # Returns the controller according to the type in the path.
      #
      # path: path Array such as from a URL
      def path_controller(path)
        @controllers[path[@path_pos]] || @controllers[nil]
      end

      # Create and return a new data instance with the provided initial value.
      # The value must be a Hash or Array. The members of the Hash or Array
      # must be nil, boolean, String, Integer, Float, BigDecimal, Array, Hash,
      # Time, URI::HTTP, or WAB::UUID. Keys to Hashes must be Symbols.
      #
      # If the repair flag is true then an attempt will be made to fix the
      # value by replacing String keys with Symbols and calling to_h or to_s
      # on unsupported Objects.
      #
      # value:: initial value
      # repair:: flag indicating invalid value should be repaired if possible
      def data(value={}, repair=false)
        Data.new(value, repair)
      end

      # Calls the model.
      def get(ref)
        @model.get(ref)
      end

      # Calls the model.
      def query(tql, handler=nil)
        @model.query(tql)
      end

    end # Shell
  end # Impl
end # WAB
