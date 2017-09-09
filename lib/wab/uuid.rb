
module WAB

  # The UUID class representing a 128 bit UUID although values are not
  # validated for conformane to the ISO/IEC specifications.
  class UUID

    attr_reader :id
    
    # Initializes a UUID from string representation of the UUID
    # following the pattern "123e4567-e89b-12d3-a456-426655440000".
    def initialize(id)
      @id = id.downcase
      raise ::WAB::ParseError.new("Invalid UUID format.") unless WAB::Utils.uuid_format?(@id)
    end

    # Returns the string representation of the UUID.
    alias to_s id

    def ==(other)
      other.is_a?(self.class) && @id == other.id
    end

  end # UUID
end # WAB
