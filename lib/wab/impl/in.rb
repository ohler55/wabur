
require 'wab/impl/pathexpr'

module WAB
  module Impl

    class In < PathExpr
      def initialize(path, *values)
        super(path)
        @values = values
      end

      def eval(data)
        @values.include?(data.get(@path))
      end

      def native()
        n = ['IN', @path]
        @values.each { |v| n << v }
        n
      end

    end # In
  end # Impl
end # WAB
