
require 'time'
require 'wab'

module WAB

  module IO

    # A Shell that uses STDIN and STDOUT for all interactions with the View
    # and Model. Since the View and Model APIs are asynchronous and Controller
    # calls are synchronous for simplicity some effort is required to block
    # where needed to achieve the difference in behavior.
    class Shell < ::WAB::Shell

      attr_reader :path_pos
      attr_reader :type_key
      attr_accessor :timeout
      attr_accessor :verbose
      
      # Sets up the shell with the designated number of processing threads and
      # the type_key.
      #
      # tcnt:: processing thread count
      # type_key:: key to use for the record type
      def initialize(tcnt, type_key='kind', path_pos=0)
        super(type_key, path_pos)
        @engine = Engine.new(self, tcnt)
        @timeout = 2.0
        @verbose = false
      end

      # Starts listening and processing.
      def start()
        @engine.start()
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
        ::WAB::Impl::Data.new(value, repair)
      end
      
      ### View related methods.

      # Push changed data to the view if it matches one of the subscription
      # filters.
      #
      # data: Wab::Data to push to the view if subscribed
      def changed(data)
        raise NotImplementedError.new
      end

      # Reply asynchronously to a view request.
      #
      # rid:: request identifier the reply is associated with
      # data:: content of the reply to be sent to the view
      def reply(rid, data)
        raise NotImplementedError.new
      end

      ### Model related methods.

      # Returns a WAB::Data that matches the object reference or nil if there
      # is no match.
      #
      # ref:: object reference
      def get(ref)
        tql = { where: ref.to_i, select: '$' }
        result = @engine.request(tql, nil, @timeout)
        if result.nil? || 0 != result[:code]
          if result.nil?
            raise ::WAB::Error.new("nil result get of #{ref}.")
          else
            raise ::WAB::Error.new("error on get of #{ref}. #{result[:error]}")
          end
        end
        result[:results]
      end

      # Evaluates the JSON TQL query. The TQL should be native Ruby objects
      # that correspond to the TQL JSON format but using Symbol keys instead
      # of strings.
      #
      # If a +handler+ is provided the call is evaluated asynchronously and
      # the handler is called with the result of the query. If a +handler+ is
      # supplied the +tql+ must contain an +:rid+ element that is unique
      # across all handlers.
      #
      # tql:: query to evaluate
      # handler:: callback handler that implements the #on_result() method
      def query(tql, handler=nil)
        @engine.request(tql, handler, @timeout)
      end

      # Subscribe to changes in stored data and push changes to the controller
      # if it passes the supplied filter.
      #
      # The +controller#changed+ method is called when changes in data cause
      # the associated object to pass the provided filter.
      #
      # controller:: the controller to notify of changed
      # filter:: the filter to apply to the data. Syntax is that TQL uses for the FILTER clause.
      def subscribe(controller, filter)
        raise NotImplementedError.new
      end

      private
      
      def form_where_eq(key, value)
        value_class = value.class
        x = ['EQ', key.to_s]
        if value.is_a?(String)
          x << "'" + value
        elsif Time == value_class
          x << value.utc.iso8601(9)
        elsif value.nil? ||
            TrueClass == value_class ||
            FalseClass == value_class ||
            Integer == value_class ||
            Float == value_class ||
            String == value_class
          x << value
        elsif 2 == RbConfig::CONFIG['MAJOR'] && 4 > RbConfig::CONFIG['MINOR'] && Fixnum == value_class
          x << value
        else
          x << value.to_s
        end
        x
      end

    end # Shell
  end # IO
end # WAB
