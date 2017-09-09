module WAB
  module Utils
    class << self
      UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
      TIME_REGEX = /^\d{4}-\d{2}-\d{2}T\d{2}\:\d{2}\:\d{2}\.\d{9}Z$/

      def ruby_series
        RbConfig::CONFIG.values_at("MAJOR", "MINOR").join.to_i
      end

      # Detect if `obj` is an instance of `Fixnum` from Ruby older than 2.4.x
      def pre_24_fixnum?(obj)
        24 > ruby_series && obj.is_a?(Fixnum)
      end

      # Determine if a given object is not an empty Hash
      def populated_hash?(obj)
        obj.is_a?(Hash) && !obj.empty?
      end

      # Detect if given string matches ISO/IEC UUID format:
      # "123e4567-e89b-12d3-a456-426655440000"
      def uuid_format?(str)
        !UUID_REGEX.match(str).nil?
      end

      # Detect if given string matches Date format:
      # "2017-09-01T12:45:15.123456789Z"
      def date_format?(str)
        !TIME_REGEX.match(str).nil?
      end
    end
  end
end
