
require 'wab/impl/pathexpr'

module WAB
  module Impl

    # Matches a node that has the same value as provided at the end of the
    # path provided. Any type is acceptable.#
    class Eq < PathExpr

      # Creates a new instance with the provided parameters.
      #
      # path:: path to the value to compare
      # value:: value to compare against
      def initialize(path, value)
        super(path)
        @value = value
      end

      def eval(data)
        data.get(@path) == @value
      end

      def native()
        ['EQ', @path, @value]
      end

    end # Eq
  end # Impl
end # WAB
