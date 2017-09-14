
module WAB
  module Impl

    # The base class for expression that are used in the TQL where and filter clauses.
    class Expr

      def initialize()
      end

      # Evaluate the expression using the supplied WAB::Data object. Each
      # expression subclass evaluates differently.
      #
      # data:: data object to evaluate against.
      def eval(_data)
        false
      end

      # Return a native Ruby representation of the expression.
      def native()
        []
      end

    end # Expr
  end # Impl
end # WAB
