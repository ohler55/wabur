
require 'wab/impl/expr'

module WAB
  module Impl

    class BoolExpr < Expr

      def initialize(*args)
        @args = args
      end

      def append_arg(arg)
        @args << arg
      end

      def eval(data)
        false
      end

    end # BoolExpr
  end # Impl
end # WAB
