
require 'wab'

# Require the concrete Expr classes so a mapping table can be created for the
# parser.
require 'wab/impl/between'
require 'wab/impl/eq'
require 'wab/impl/gt'
require 'wab/impl/gte'
require 'wab/impl/has'
require 'wab/impl/in'
require 'wab/impl/lt'
require 'wab/impl/lte'
require 'wab/impl/regex'

require 'wab/impl/and'
require 'wab/impl/or'
require 'wab/impl/not'

module WAB
  module Impl
    class Expr
      @xmap = {
        between: Between,
        eq: Eq,
        gt: Gt,
        gte: Gte,
        in: In,
        has: Has,
        lt: Lt,
        lte: Lte,
        regex: Regex,
        and: And,
        or: Or,
        not: Not,
      }

      # Parses an Array into a set of Expr subsclasses.
      #
      # native:: native Ruby representation of the expression.
      def self.parse(native)
        raise ::WAB::Error.new('Invalid expression. Must be an Array.') unless native.is_a?(Array)
        op = native[0]
        op = op.downcase.to_sym unless op.is_a?(Symbol)
        xclass = @xmap[op]
        raise ::WAB::Error.new("#{op} is not a valid expression function.") if xclass.nil?
        args = []
        native[1..-1].each { |n|
          args << if n.is_a?(Array)
                    parse(n)
                  elsif n.is_a?(String)
                    if 0 < n.length
                      if '\'' == n[0]
                        n[1..-1]
                      else
                        ::WAB::Impl::Data.detect_string(n)
                      end
                    end
                  else
                    n
                  end
        }
        xclass.new(*args)
      end

    end # Expr
  end # Impl
end # WAB
