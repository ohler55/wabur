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

    # Starts the shell.
    def start()
      raise NotImplementedError.new
    end

    # Returns the path where a data type is located. The default is 'kind'.
    def type_key()
      raise NotImplementedError.new
    end

    # Returns the position of the type in a path.
    def path_pos()
      raise NotImplementedError.new
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
    # tql:: query to evaluate
    def query(tql)
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
