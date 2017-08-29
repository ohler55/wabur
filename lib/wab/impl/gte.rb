
require 'wab/impl/pathexpr'

module WAB
  module Impl

    class Gte < PathExpr
      def initialize(path, value)
        super(path)
        @value = value
      end

      def eval(data)
        data.get(@path) >= @value
      end

      def native()
        ['GTE', @path, @value]
      end

    end # Gte
  end # Impl
end # WAB
