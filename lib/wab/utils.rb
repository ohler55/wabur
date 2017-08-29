module WAB
  module Utils
    class << self
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
    end
  end
end
