
module WAB
  module Impl

    module Utils
      class << self

        # Convert a key to an +Integer+ or raise.
        def key_to_int(key)
          return key if key.is_a?(Integer)

          key = key.to_s if key.is_a?(Symbol)
          if key.is_a?(String)
            i = key.to_i
            return i if i.to_s == key
          end
          return key if WAB::Utils.pre_24_fixnum?(key)

          raise WAB::Error, 'path key must be an integer for an Array.'
        end

        # Returns either an +Integer+ or +nil+.
        def attempt_key_to_int(key)
          return key if key.is_a?(Integer)

          key = key.to_s if key.is_a?(Symbol)
          if key.is_a?(String)
            i = key.to_i
            return i if i.to_s == key
          end
          return key if WAB::Utils.pre_24_fixnum?(key)
          nil
        end
      end

    end # Utils
  end # Impl
end # WAB
