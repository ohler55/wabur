
module WAB
  module Impl

    # Match any node that has a value equal to one of the values provided in
    # the argument list after the path. This can be used with any type.
    class In < PathExpr

      # Creates a new instance with the provided parameters.
      #
      # path:: path to the value to compare
      # values:: values to compare to
      def initialize(path, *values)
        super(path)
        @values = values
      end

      def eval(data)
        @values.include?(data.get(@path))
      end

      def native()
        n = ['IN', @path]
        @values.each { |v| n << v }
        n
      end

    end # In
  end # Impl
end # WAB
