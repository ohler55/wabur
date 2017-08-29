
require 'wab/impl/expr'

module WAB
  module Impl

    class Not < Expr
      def initialize(arg)
        super()
        @arg = arg
      end

      def eval(data)
        !@arg.eval(data)
      end

      def native()
        ['NOT', @arg.native]
      end

    end # Not
  end # Impl
end # WAB
