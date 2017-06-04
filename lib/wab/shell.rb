module WAB

  # The Shell is a duck-typed class. Any shell alternative should implement
  # all the methods defined in the class except the +initialize+ method. This
  # class is also the default Ruby version of the shell that can be used for
  # development and small systems.
  class Shell

    # Sets up the shell with a view, model, and type_key.
    def initialize(view, model, type_key='kind')
      @view = view
      @model = model
      @controllers = {}
      @type_key = type_key
    end

    # Returns the view instance that can be used for pushing data to a view.
    def view()
      @view
    end

    # Returns the model instance that can be used to get and modify data in
    # the data store.
    def model()
      @model
    end

    # Returns the path where a data type is located. The default is 'kind'.
    def type_key()
      @type_key
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

  end # Shell
end # WAB
