
require 'wab/impl/handler'
require 'wab/impl/model'

module WAB
  module Impl

    # The shell for reference Ruby implementation.
    class Shell
      include WAB::ShellLogger
      extend Forwardable

      attr_accessor :verbose

      # Returns the path where a data type is located. The default is 'kind'.
      attr_reader :type_key
      attr_reader :path_pos

      # Call the Model instance with these methods.
      def_delegators :@model, :get, :query

      # Sets up the shell with the supplied configuration data.
      #
      # config:: configuration Hash
      def initialize(config)
        pre_path  = config['handler']['path']
        @path_pos = pre_path.split('/').length - 1

        @model    = Model.new(File.join(config['base'], config['data_dir']))
        @type_key = config['type_key']

        @verbose  = if config.has_key?('verbose')
                      verbosity = config['verbose'].to_s.downcase
                      if verbosity == 'true'
                        true
                      elsif verbosity == 'false'
                        false
                      end
                    end

        @http_dir    = File.expand_path(config['http']['dir'])
        @http_port   = config['http']['port'].to_i
        @controllers = {}
      end

      # Start listening. This should be called after registering Controllers
      # with the Shell.
      def start()
        server = WEBrick::HTTPServer.new(Port: @http_port, DocumentRoot: @http_dir)
        server.mount('/v1', WAB::Impl::Handler, self)

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
