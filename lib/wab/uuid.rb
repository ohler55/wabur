
module WAB

  # The UUID class representing a 128 bit UUID although values are not
  # validated for conformane to the ISO/IEC specifications.
  class UUID

    attr_reader :id
    
    # Initializes a UUID from string representation of the UUID
    # following the pattern "123e4567-e89b-12d3-a456-426655440000".
    def initialize(id)
      @id = id.downcase
      # TBD change to WAB exception
      raise Exception.new("Invalid UUID format.") if /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.match(@id).nil?
    end

    # Returns the string representation of the UUID.
    def to_s
      @id
    end

    def ==(other)
      other.is_a?(self.class) && @id == other.id
    end

  end # UUID
end # WAB
