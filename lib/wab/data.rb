
module WAB

  # The class representing the cananical data structure in WAB. Typically the
  # Data instances are factory created by the Shell and will most likely not
  # be instance of this class but rather a class that is a duck-type of this
  # class (has the same methods and behavior).
  class Data

    # This method is included only for testing purposes of the Ruby base
    # Shell. It should only be called by the Shell. Create a new Data instance
    # with the initial value provided. The value must be a Hash or Array. The
    # members of the Hash or Array must be nil, boolean, String, Integer,
    # Float, BigDecimal, Array, Hash, Time, WAB::UUID, or WAB::IRI.
    def initialize(value=nil)
      # TBD
    end

    # Gets the Data element or value identified by the path where the path
    # elements are separated by the '.' character. The path can also be a
    # array of path node identifiers. For example, child.grandchild is the
    # same as ['child', 'grandchild'].
    def get(path)
      # TBD
    end
    
    # Sets the node value identified by the path where the path elements are
    # separated by the '.' character. The path can also be a array of path
    # node identifiers. For example, child.grandchild is the same as ['child',
    # 'grandchild']. The value must be one of the allowed data values
    # described in the initialize method.
    def set(path, value)
      # TBD
    end

    # Each child of the Data instance is provided as an argument to a block
    # when the each method is called.
    def each()
      # TBD
    end

    # Each leaf of the Data instance is provided as an argument to a block
    # when the each method is called. A leaf is a primitive that has no
    # children and will be nil, a Boolean, String, Numberic, Time, WAB::UUID,
    # or WAB::IRI.
    def each_leaf()
      # TBD
    end

    # Make a deep copy of the Data instance.
    def clone()
      # TBD
    end

    # Returns the instance converted to native Ruby values such as a Hash,
    # Array, etc.
    def native()
      # TBD
    end

    # Returns true if self and other are either the same or have the same
    # contents. This is a deep comparison.
    def eql?(other)
      # TBD
    end

    # Encode the data as a JSON string.
    def json(indent=0)
      # TBD
    end

  end # Data
end # WAB
