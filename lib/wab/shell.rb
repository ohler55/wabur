module WAB

  # The Shell is a duck-typed class. Any shell alternative should implement
  # all the methods defined in the class except the +initialize+ method.  The
  # Shell acts as the conduit between the View and Model portions of the MVC
  # design pattern.
  #
  # As the View conduit the Shell usually makes calls to the controller. The
  # exception to this control flow direction is when data changes and is
  # pushed out to the view.
  # 
  # As the Model, the Shell must respond to request to update the store using
  # either the CRUD type operations that match the controller.
  #
  # Note that this class implementes some basic features related to controller
  # management but those features can be implemented in other ways as long as
  # the methods remain the same.
  class Shell

    # Returns the path where a data type is located. The default is 'kind'.
    attr_reader :type_key

    # Sets up the shell with a type_key and path position.
    #
    # type_key:: key for the type associated with a record
    # path_pos:: position in a URL path that is the class or type
    def initialize(type_key='kind', path_pos=0)
      @controllers = {}
      @type_key = type_key
      @path_pos = path_pos
    end

    # Starts the shell.
    def start()
    end

    # Returns the path where a data type is located. The default is 'kind'.
    def type_key()
      @type_key
    end

    # Returns the position of the type in a path.
    def path_pos()
      @path_pos
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
        return @controllers[path[@path_pos]] || @controllers[nil]
      end
      @controllers[nil]
    end

    # Create and return a new data instance with the provided initial value.
    # The value must be a Hash or Array. The members of the Hash or Array must
    # be nil, boolean, String, Integer, Float, BigDecimal, Array, Hash, Time,
    # URI::HTTP, or WAB::UUID. Keys to Hashes must be Symbols.
    #
    # If the repair flag is true then an attempt will be made to fix the value
    # by replacing String keys with Symbols and calling to_h or to_s on
    # unsupported Objects.
    #
    # value:: initial value
    # repair:: flag indicating invalid value should be repaired if possible
    def data(value=nil, repair=false)
      raise NotImplementedError.new
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
      raise NotImplementedError.new
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
      raise NotImplementedError.new
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

  end # Shell
end # WAB
