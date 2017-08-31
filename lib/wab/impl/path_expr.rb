
module WAB
  module Impl

    class PathExpr < Expr

      def initialize(path)
        super()
        @path = path
      end

    end # PathExpr
  end # Impl
end # WAB
