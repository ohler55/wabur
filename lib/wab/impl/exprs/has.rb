
module WAB
  module Impl

    # Used to filters out all nodes that do not have a node at the end of the
    # provided path.
    class Has < PathExpr

      # Creates a new instance with the provided parameters.
      #
      # path:: path to the value to check
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
