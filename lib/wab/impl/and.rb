
require 'wab/impl/boolexpr'

module WAB
  module Impl

    # A logical AND expression.
    class And < BoolExpr

      # Create an AND expression with the provided arguments which must be
      # instances of subclasses of the Expr class.
      #
      # args:: argument to the AND expression
      def initialize(*args)
        super
      end

      def eval(data)
        @args.each { |a|
          return false unless a.eval(data)
        }
        true
      end

      def native()
        @args.map { |a| a.native }.unshift('AND')
      end

    end # And
  end # Impl
end # WAB
