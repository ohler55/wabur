module WAB

  # The Shell is a duck-typed class. Any shell alternative should implement
  # all the methods defined in the class except the +initialize+ method. This
  # class is also the default Ruby version of the shell that can be used for
  # development and small systems.
  class Shell
    # Returns the view instance that can be used for pushing data to a view.
    attr_reader :view

    # Returns the model instance that can be used to get and modify data in
    # the data store.
    attr_reader :model

    # Returns the path where a data type is located. The default is 'kind'.
    attr_reader :type_key

    # Sets up the shell with a view, model, and type_key.
    def initialize(view, model, type_key = 'kind')
      @view = view
      @model = model
      @controllers = {}
      @type_key = type_key
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

  end # Shell
end # WAB
