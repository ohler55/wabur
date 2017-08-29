
require 'wab/impl/pathexpr'

module WAB
  module Impl

    class Gt < PathExpr
      def initialize(path, value)
        super(path)
        @value = value
      end

      def eval(data)
        data.get(@path) > @value
      end

      def native()
        ['GT', @path, @value]
      end

    end # Gt
  end # Impl
end # WAB
