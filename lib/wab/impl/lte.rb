
require 'wab/impl/pathexpr'

module WAB
  module Impl

    class Lte < PathExpr
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
