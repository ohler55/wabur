
require 'time'
require 'wab/impl'

module WAB
  module IO

    # A Shell that uses STDIN and STDOUT for all interactions with the View
    # and Model. Since the View and Model APIs are asynchronous and Controller
    # calls are synchronous for simplicity some effort is required to block
    # where needed to achieve the difference in behavior.
    class Shell
      include WAB::ShellLogger

      attr_reader :path_pos
      attr_reader :type_key
      attr_accessor :timeout

      # Sets up the shell with the designated number of processing threads and
      # the type_key.
      #
      # tcnt:: processing thread count
      # type_key:: key to use for the record type
      def initialize(tcnt, type_key='kind', path_pos=0)
        @controllers = {}
        @type_key = type_key
        @path_pos = path_pos
        @engine = Engine.new(self, tcnt)
        @timeout = 2.0
        @logger = Logger.new(STDERR)
        logger.level = Logger::WARN
      end

      # Starts listening and processing.
      def start()
        @engine.start
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
        WAB::Impl::Data.new(value, repair)
      end

      ### View related methods.

      # Push changed data to the view if it matches one of the subscription
      # filters.
      #
      # data: Wab::Data to push to the view if subscribed
      def changed(_data)
        raise NotImplementedError.new
      end

      ### Model related methods.

      # Returns a WAB::Data that matches the object reference or nil if there
      # is no match.
      #
      # ref:: object reference
      def get(ref)
        result = query(where: ref.to_i, select: '$')
        raise WAB::Error.new("nil result get of #{ref}.") if result.nil?
        raise WAB::Error.new("error on get of #{ref}. #{result[:error]}") if 0 != result[:code]

        ra = result[:results]
        return nil if (ra.nil? || 0 == ra.length)
        ra[0]
      end

      # Evaluates the JSON TQL query. The TQL should be native Ruby objects
      # that correspond to the TQL JSON format but using Symbol keys instead
      # of strings.
      #
      # tql:: query to evaluate
      def query(tql)
        @engine.request(tql, @timeout)
      end

      # Subscribe to changes in stored data and push changes to the controller
      # if it passes the supplied filter.
      #
      # The +controller#changed+ method is called when changes in data cause
      # the associated object to pass the provided filter.
      #
      # controller:: the controller to notify of changed
      # filter:: the filter to apply to the data. Syntax is that TQL uses for the FILTER clause.
      def subscribe(_controller, _filter)
        raise NotImplementedError.new
      end

    end # Shell
  end # IO
end # WAB
