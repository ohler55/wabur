
module WAB
  module Impl

    class PathExpr < Expr

      def initialize(path)
        super()
        @path = path
      end

      private
      attr_reader :path

    end # PathExpr
  end # Impl
end # WAB
