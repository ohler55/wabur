
module WAB
  module Impl

    # Matches a node that has a value less than or equal to the provided
    # value. If a integer or float is provided then both integer and floats
    # are checked. If the value provided is a time then only time nodes are
    # checked. Any other type results in an error.
    class Lte < PathExpr

      # Creates a new instance with the provided parameters.
      #
      # path:: path to the value to compare
      # value:: value to compare against
      def initialize(path, value)
        super(path)
        @value = value
      end

      def eval(data)
        data.get(@path) <= @value
      end

      def native()
        ['LTE', @path, @value]
      end

    end # Lte
  end # Impl
end # WAB
