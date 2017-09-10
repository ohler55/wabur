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
    def initialize(shell)
      @shell = shell
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
    # On error an Exception should be raised.
    #
    # path:: array of tokens in the path.
    # query:: query parameters from a URL.
    # data:: the data to use as a new object.
    def create(path, query, data) # :doc:
      tql = { }
      kind = path[@shell.path_pos]
      if WAB::Utils.populated_hash?(query)
        tql[:where] = and_where(kind, query)
      end
      tql[:insert] = data.native
      shell_query(tql, kind, 'create')
    end

    # Return the objects according to the path and query arguments. The
    # following patterns supported:
    #
    # * [MyType/12345] looks for MyType with reference ID of 12345
    # * [MyType?name=fred&age=63] looks for all MyTypes with a name of 'fred'
    #                             and an age of 63.
    # * [MyType/list?Name=name&Age=age] returns only the name and age
    #                                   attributes and places them in a Hash
    #                                   with the keys :Name and :Age along
    #                                   with the record reference as :ref.
    #
    # path:: array of tokens in the path.
    # query:: query parameters from a URL as a Hash with key and value
    #         pairs. Note that duplicate keys will result in only the last
    #         option being present,
    def read(path, query) # :doc:
      kind = path[@shell.path_pos]
      # Check for the type and object reference pattern as well as the list
      # pattern.
      if @shell.path_pos + 2 == path.length
        ref = path[@shell.path_pos + 1]
        return list_select(kind, query) if 'list' == ref

        # Read a single object/record.
        ref = ref.to_i
        obj = @shell.get(ref)
        obj = obj.native if obj.is_a?(::WAB::Data)
        results = []
        results << {id: ref, data: obj} unless obj.nil?
        @shell.data({ code: 0, results: results})
      else
        list_match(kind, query)
      end
    end

    # A private method to gather sets of Hashes that include the fields
    # specified in the fields Hash.
    def list_select(kind, fields)
      tql = { }
      select = { ref: '$ref' }
      if WAB::Utils.populated_hash?(fields)
        fields.each_pair { |k,v| select[k] = v }
      end
      tql[:where] = form_where_eq(@shell.type_key, kind)
      tql[:select] = select
      shell_query(tql, kind, 'read')
    end

    # A private method to gather a list of objects that match the query
    # parameters.
    def list_match(kind, query)
      tql = { }
      # If there is a query set up a where clause.
      tql[:where] = if WAB::Utils.populated_hash?(query)
                      and_where(kind, query)
                    else
                      form_where_eq(@shell.type_key, kind)
                    end
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
      elsif WAB::Utils.populated_hash?(query)
        tql[:where] = and_where(kind, query)
      else
        raise ::WAB::Error.new("update on all #{kind} not allowed.")
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
      tql[:where] = if @shell.path_pos + 2 == path.length # has an object reference in the path
                      path[@shell.path_pos + 1].to_i
                    elsif WAB::Utils.populated_hash?(query)
                      and_where(kind, query)
                    else
                      form_where_eq(@shell.type_key, kind)
                    end
      tql[:delete] = nil
      shell_query(tql, kind, 'delete')
    end

    # Called when an asynchronous query is made and the results become
    # available.
    #
    # data:: results of the query
    def on_result(data)
      data = data.native if data.is_a?(::WAB::Data)
      $stdout.puts(@shell.data({rid: data[:rid], api: 2, body: data}).json)
      $stdout.flush
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
      x << if Time == value_class
             value.utc.iso8601(9)
           elsif value.nil? ||
               TrueClass == value_class ||
               FalseClass == value_class ||
               Integer == value_class ||
               Float == value_class
             value
           elsif String == value_class
             # if the string matches a detectable type then don't quote it
             detect_string(value)
           elsif WAB::Utils.pre_24_fixnum?(value)
             value
           else
             value.to_s
           end
      x
    end

    # Form an AND expression for a TQL where clause.
    def and_where(kind, query)
      where = ['AND']
      where << form_where_eq(@shell.type_key, kind)
      query.each_pair { |k,v| where << form_where_eq(k, v) }
      where
    end

    # Detects strings that are representation of something else such as an
    # integer, UUID, Time, or URI. Used to convert URL query parameters to TQL
    # types. That also means string are quoted for TQL with a single leading
    # single quote character unless one is already present. No trailing single
    # quote is added.
    def detect_string(value)
      # if the string matches a detectable type then don't quote it
      # ok as is
      return value if !value.empty? && value.start_with?("'")

      if !/^-?\d+$/.match(value).nil?
        value.to_i
      elsif !/^-?\d*\.?\d+([eE][-+]?\d+)?$/.match(value).nil?
        value.to_f
      elsif WAB::Utils.uuid_format?(value)
        WAB::UUID.new(value)
      elsif WAB::Utils.wab_time_format?(value)
        begin
          DateTime.parse(value).to_time
        rescue
          "'" + value
        end
      elsif value.downcase.start_with?('http://')
        begin
          URI(value)
        rescue
          "'" + value
        end
      else
        "'" + value
      end
    end

    # Helper to send TQL requests to the shell.
    def shell_query(tql, kind, op)
      result = @shell.query(tql)
      raise WAB::Error.new("nil result on #{kind} #{op}.") if result.nil?
      raise WAB::Error.new("error on #{kind} #{op}. #{result[:error]}") if 0 != result[:code]
      result
    end

  end # Controller
end # WAB
