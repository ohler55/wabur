
module WAB
  module Impl

    # Negates and expression.
    class Not < Expr

      # Create an NOT expression with the provided argument which must be an
      # instance of a subclass of the Expr class.
      #
      # arg:: argument to the NOT expression
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
