
require 'wab/impl/boolexpr'

module WAB
  module Impl

    class And < BoolExpr
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
        n = ['AND']
        @args.each { |a| n << a.native }
        n
      end

    end # And
  end # Impl
end # WAB
