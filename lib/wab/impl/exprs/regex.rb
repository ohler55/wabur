
module WAB
  module Impl

    class Regex < PathExpr

      # Creates a new instance with the provided parameters.
      #
      # path:: path to the value to compare
      # rx:: regexp to match against a string value from the path lookup
      def initialize(path, rx)
        super(path)
        @rx = rx.is_a?(Regexp) ? rx : Regexp.new(rx.to_s)
      end

      def eval(data)
        value = data.get(@path)
        return @rx === value if value.is_a?(String)
        false
      end

      def native()
        ['REGEX', @path, @rx.source]
      end

    end # Regex
  end # Impl
end # WAB
