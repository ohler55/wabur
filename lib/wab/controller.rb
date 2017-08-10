module WAB

  # A Controller class or a duck-typed alternative should be created and
  # registered with a Shell for any type that implements behavior other than
  # the default REST API processing. If a public method is not found on the
  # class instance then the default REST API processing will be used.
  #
  # A description of the available methods is included as private methods.
  class Controller # :doc: all
    attr_accessor :shell

    # Create a instance.
    def initialize(shell, async=false)
      @shell = shell
      # TBD handle async
    end

    # Handler for paths that do not match the REST pattern or for unregistered
    # types. Only called on the default controller.
    #
    # Processing result are passed back to the view which forward the result
    # on to the requester. The result, if not nil, should be a Data instance.
    #
    # data:: data to be processed
    def handle(data)
      nil
    end

    # To make the desired methods active while processing the desired method
    # should be made public in the subclasses. If the methods remain private
    # they will not be called.
    private

    # Create a new data object. If a query is provided it is treated as a
    # check against an existing object with the same key/value pairs.
    #
    # The reference to the object created is returned on success.
    #
    # On error an Exception should be raised.
    #
    # path:: array of tokens in the path.
    # query:: query parameters from a URL.
    # data:: the data to use as a new object.
    def create(path, query, data) # :doc:
      tql = { }
      kind = path[@shell.path_pos]
      if query.is_a?(Hash) && 0 < query.size
        where = ['AND']
        where << form_where_eq(@shell.type_key, kind)
        query.each_pair { |k,v| where << form_where_eq(k, v) }
        tql[:where] = where
      end
      tql[:insert] = data.native
      shell_query(tql, kind, 'create')
    end

    # Return the objects according to the path and query arguments.
    #
    # If the path includes an object reference then that object is returned as
    # the only member of the results list of a WAB::Data returned.
    #
    # If there is no object reference in the path then the attributes are used
    # to find matching objects. The objects that have the same key/value pairs
    # are returned.
    #
    # path:: array of tokens in the path.
    # query:: query parameters from a URL as a Hash with keys matching paths
    #         into the target objects and value equal to the target attribute
    #         values. A path can be an array of keys used to walk a path to
    #         the target or a +.+ delimited set of keys.
    def read(path, query) # :doc:
      if @shell.path_pos + 2 == path.length # has an object reference in the path
        ref = path[@shell.path_pos + 1].to_i
        obj = @shell.get(ref)
        obj = obj.native if obj.is_a?(::WAB::Data)
        return @shell.data({ code: 0, results: [ { id: ref, data: obj } ]})
      end
      tql = { }
      kind = path[@shell.path_pos]
      # No id so must be either a simple query by attribute or a list.
      if query.is_a?(Hash) && 0 < query.size
        where = ['AND']
        where << form_where_eq(@shell.type_key, kind)
        query.each_pair { |k,v| where << form_where_eq(k, v) }
      else
        where = form_where_eq(@shell.type_key, kind)
      end
      tql[:where] = where
      tql[:select] = { id: '$ref', data: '$' }
      shell_query(tql, kind, 'read')
    end

    # Replaces the object data for the identified object.
    #
    # The return should be the identifiers for the object updated.
    #
    # On error an Exception should be raised.
    #
    # path:: array of tokens in the path.
    # query:: query parameters from a URL.
    # data:: the data to use as a new object.
    def update(path, query, data) # :doc:
      tql = { }
      kind = path[@shell.path_pos]
      if @shell.path_pos + 2 == path.length # has an object reference in the path
        tql[:where] = path[@shell.path_pos + 1].to_i
      elsif query.is_a?(Hash) && 0 < query.size
        where = ['AND']
        where << form_where_eq(@shell.type_key, kind)
        query.each_pair { |k,v| where << form_where_eq(k, v) }
        tql[:where] = where
      else
        # TBD use WAB exception
        raise Exception.new("update on all #{kind} not allowed.")
      end
      tql[:update] = data.native
      shell_query(tql, kind, 'update')
    end

    # Delete the identified object.
    #
    # On success the deleted object identifier is returned. If the object is
    # not found then nil is returned. On error an Exception should be raised.
    #
    # If no +id+ is present in the path then the return should be a Hash where
    # the keys are the matching object identifiers and the value are the
    # object data. An empty Hash or nil indicates there were no matches.
    #
    # path:: identifier of the object to be deleted
    # query:: query parameters from a URL as a Hash with keys matching paths
    #         into the target objects and value equal to the target attribute
    #         values. A path can be an array of keys used to walk a path to
    #         the target or a +.+ delimited set of keys.
    def delete(path, query) # :doc:
      tql = { }
      kind = path[@shell.path_pos]
      if @shell.path_pos + 2 == path.length # has an object reference in the path
        tql[:where] = path[@shell.path_pos + 1].to_i
      elsif query.is_a?(Hash) && 0 < query.size
        where = ['AND']
        where << form_where_eq(@shell.type_key, kind)
        query.each_pair { |k,v| where << form_where_eq(k, v) }
        tql[:where] = where
      else
        tql[:where] = form_where_eq(@shell.type_key, kind)
      end
      tql[:delete] = nil
      shell_query(tql, kind, 'delete')
    end

    # Subscribe to changes in data pushed from the model that will be passed
    # to the view with the +push+ method if it passes the supplied filter.
    #
    # The +view+ +changed+ method is called when changes in data cause
    # the associated object to pass the provided filter.
    #
    # filter:: the filter to apply to the data. TBD the nature of the filter is pending.
    def subscribe(filter)
      # TBD
    end

    # Called by the model when data changes if supported by the model storage
    # component.
    #
    # data:: the data that has changed
    def changed(data) # :doc:
      # TBD filter accoding to subscriptions
      @shell.changed(data)
    end

    # Form a EQ expression for a TQL where clause. Used as a helper to the
    # primary API calls.
    #
    # key:: key in the expression
    # value:: value portion converted to the correct format if necessary
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

    # Helper to send TQL requests to the shell either synchronously or
    # asynchronously depending on the controller type.
    def shell_query(tql, kind, op)

      # TBD check for async or not

      result = @shell.query(tql, nil) # synchronous call
      if result.nil? || 0 != result[:code]
        if result.nil?
          # TBD use WAB specific exception
          raise Exception.new("nil result on #{kind} #{op}.")
        else
          # TBD use WAB specific exception
          raise Exception.new("error on #{kind} #{op}. #{result[:error]}")
        end
      end
      result
    end

  end # Controller
end # WAB
