
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
      attr_reader :pre_path
      attr_reader :mounts
      attr_reader :http_dir
      attr_reader :http_port
      attr_reader :tql_path
      attr_reader :export_proxy

      attr_accessor :indent
      
      # Call the Model instance with these methods.
      def_delegators :@model, :get, :query

      # Sets up the shell with the supplied configuration data.
      #
      # config:: Configuration object
      def initialize(config)
        @indent       = config[:indent].to_i || 0
        @pre_path     = config[:path_prefix] || '/v1'
        @path_pos     = @pre_path.split('/').length - 1
        @tql_path     = config[:tql_path] || '/tql'
        base          = config[:base] || '.'
        @model        = Model.new((config['store.dir'] || File.join(base, 'data')).gsub('$BASE', base), indent)
        @type_key     = config[:type_key] || 'kind'
        @logger       = config[:logger]
        @logger.level = config[:verbosity] unless @logger.nil?
        @http_dir     = (config['http.dir'] || File.join(base, 'pages')).gsub('$BASE', base)
        @http_port    = (config['http.port'] || 6363).to_i
        @export_proxy = config[:export_proxy]
        @export_proxy = true if @export_proxy.nil? # The default is true if not present.
        @controllers  = {}
        @mounts       = config[:handler] || []
	@server       = config['http.server'].to_s.downcase
        requires      = config[:require]
        case requires
        when Array
          requires.each { |r| require r.strip }
        when String
          requires.split(',').each { |r| require r.strip }
        end
      end

      # Start listening. This should be called after registering Controllers
      # with the Shell.
      def start
	case @server
	when 'agoo'
	  require 'wab/impl/agoo'
	  WAB::Impl::Agoo::Server::start(self)
	when 'sinatra'
	  require 'wab/impl/sinatra'
	  WAB::Impl::Sinatra::Server::start(self)
	else
	  require 'wab/impl/webrick'
	  WAB::Impl::WEBrick::Server::start(self)
	end
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
	@mount << { type: type, handler: controller }
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

      # Helper function that creates a controller instance given either a
      # class name, a class, or an already created object.
      def create_controller(controller)
        case controller
        when String
          controller = Object.const_get(controller).new(self)
        when Class
          controller = controller.new(self)
        end
        controller.shell = self
        controller
      end

      def log_call(controller, op, path, query, body=nil)
	if @logger.debug?
	  if body.nil?
	    @logger.debug("#{controller.class}.#{op}(#{path_to_s(path)}#{query})")
	  else
	    body = body.json(@indent) unless body.is_a?(String)
	    @logger.debug("#{controller.class}.#{op}(#{path_to_s(path)}#{query})\n#{body}")
	  end
	elsif @logger.info?
	  @logger.info("#{controller.class}.#{op}(#{path_to_s(path)}#{query})") if @logger.info?
	end
      end

      private

      def path_to_s(path)
	if path.is_a?(String)
	  path
	elsif path.is_a?(Array)
	  path.join('/')
	else
	  path.to_s
	end
      end

    end # Shell
  end # Impl
end # WAB
