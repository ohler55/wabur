
require 'wab/impl/boolexpr'

module WAB
  module Impl

    class Or < BoolExpr
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
        n = ['OR']
        @args.each { |a| n << a.native }
        n
      end

    end # Or
  end # Impl
end # WAB
