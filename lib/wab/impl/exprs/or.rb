
module WAB
  module Impl

    # A logical OR expression.
    class Or < BoolExpr

      # Create an OR expression with the provided arguments which must be
      # instances of subclasses of the Expr class.
      #
      # args:: argument to the OR expression
      def initialize(*args)
        super
      end

      def eval(data)
        @args.each { |a|
          return true if a.eval(data)
        }
        false
      end

      def native()
        @args.map(&:native).unshift('OR')
      end

    end # Or
  end # Impl
end # WAB
