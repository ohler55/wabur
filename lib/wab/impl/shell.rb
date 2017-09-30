
require 'wab/impl/handler'
require 'wab/impl/model'

module WAB
  module Impl

    # The shell for reference Ruby implementation.
    class Shell
      include WAB::ShellLogger
      extend Forwardable

      # Returns the path where a data type is located. The default is 'kind'.
      attr_reader :type_key
      attr_reader :path_pos

      # Call the Model instance with these methods.
      def_delegators :@model, :get, :query

      # Sets up the shell with the supplied configuration data.
      #
      # config:: Configuration object
      def initialize(config)
        @pre_path     = config[:path_prefix] || '/v1'
        @path_pos     = @pre_path.split('/').length - 1
        base          = config[:base] || '.'
        @model        = Model.new((config['store.dir'] || File.join(base, 'data')).gsub('$BASE', base))
        @type_key     = config[:type_key] || 'kind'
        @logger       = config[:logger]
        @logger.level = config[:verbosity] unless @logger.nil?
        @http_dir     = (config['http.dir'] || File.join(base, 'pages')).gsub('$BASE', base)
        @http_port    = (config['http.port'] || 6363).to_i
        @export_proxy = config['export_proxy']
        @export_proxy = true if @export_proxy.nil? # The default is true if not present.
        @controllers  = {}

        requires      = config[:require]
        case requires
        when Array
          requires.each { |r| require r.strip }
        when String
          requires.split(',').each { |r| require r.strip }
        end

        if config[:handler].is_a?(Array)
          config[:handler].each { |hh| register_controller(hh[:type], hh[:handler]) }
        end
      end

      # Start listening. This should be called after registering Controllers
      # with the Shell.
      def start()
        mime_types = WEBrick::HTTPUtils::DefaultMimeTypes
        mime_types['es6'] = 'application/javascript'
        server = WEBrick::HTTPServer.new(Port: @http_port,
                                         DocumentRoot: @http_dir,
                                         MimeTypes: mime_types)
        server.mount(@pre_path, Handler, self)
        server.mount('/', ExportProxy, @http_dir) if @export_proxy

        trap 'INT' do server.shutdown end
        server.start
      end

      # Register a controller for a named type.
      #
      # If a request is received for an unregistered type the default controller
      # will be used. The default controller is registered with a +nil+ key.
      #
      # type:: type name
      # controller:: Controller instance for handling requests for the
      #              identified +type+. This can be a Controller, a Controller
      #              class, or a Controller class name.
      def register_controller(type, controller)
        case controller
        when String
          controller = Object.const_get(controller).new(self)
        when Class
          controller = controller.new(self)
        end
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
        path = path.native if path.is_a?(WAB::Data)
        return path_controller(path) unless path.nil? || (path.length <= @path_pos)

        content = data.get(:content)
        return @controllers[content.get(@type_key)] || @controllers[nil] unless content.nil?

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

    end # Shell
  end # Impl
end # WAB
