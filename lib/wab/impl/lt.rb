
require 'wab/impl/pathexpr'

module WAB
  module Impl

    class Lt < PathExpr
      def initialize(path, value)
        super(path)
        @value = value
      end

      def eval(data)
        data.get(@path) < @value
      end

      def native()
        ['LT', @path, @value]
      end

    end # Lt
  end # Impl
end # WAB
