
require 'wab'

module WAB
  module Impl

    class Expr

      def initialize()
        @args = []
      end

      def append_arg(arg)
        @args << arg
      end

      def eval(data)
        nil
      end

    end # Expr
  end # Impl
end # WAB

# Require the concrete Expr classes so a mapping table can be created for the
# parser.
require 'wab/impl/eq'

module WAB
  module Impl
    class Expr
      @xmap = {
        'eq' => Eq,
      }

      # Parses an Array into a set of Expr and subsclasses.
      def self.parse(jq)
      end

    end # Expr
  end # Impl
end # WAB
