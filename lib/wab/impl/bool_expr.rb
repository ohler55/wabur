
module WAB
  module Impl

    class BoolExpr < Expr

      # Create an expression with the provided arguments which must be
      # instances of subclasses of the Expr class.
      #
      # args:: argument to the expression
      def initialize(*args)
        @args = args
      end

      def append_arg(arg)
        @args << arg
      end

      def eval(_data)
        false
      end

    end # BoolExpr
  end # Impl
end # WAB
