
require 'wab/impl/pathexpr'

module WAB
  module Impl

    class Between < PathExpr
      def initialize(path, min, max, min_incl=true, max_incl=true)
        super(path)
        @min = min
        @max = max 
        @min_incl = min_incl
        @max_incl = max_incl
      end

      def eval(data)
        value = data.get(@path)
        return false if (@min_incl ? value < @min : value <= @min)
        return false if (@max_incl ? @max < value : @max <= value)
        true
      end

      def native()
        ['BETWEEN', @path, @min, @max, @min_incl, @max_incl]
      end

    end # Between
  end # Impl
end # WAB
