
require 'wab/impl/pathexpr'

module WAB
  module Impl

    class Has < PathExpr
      def initialize(path)
        super(path)
      end

      def eval(data)
        data.has?(@path)
      end

      def native()
        ['HAS', @path]
      end

    end # Has
  end # Impl
end # WAB
