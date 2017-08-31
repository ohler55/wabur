
require 'wab'

module WAB
  # Web Application Builder implementation of the WAB APIs.
  module Impl
  end
end

require 'wab/impl/data'
require 'wab/impl/expr'
require 'wab/impl/path_expr'
require 'wab/impl/bool_expr'
require 'wab/impl/shell'

# Require the concrete Expr subclasses so a mapping table can be created for
# the parser.

require 'wab/impl/exprs/between'
require 'wab/impl/exprs/eq'
require 'wab/impl/exprs/gt'
require 'wab/impl/exprs/gte'
require 'wab/impl/exprs/has'
require 'wab/impl/exprs/in'
require 'wab/impl/exprs/lt'
require 'wab/impl/exprs/lte'
require 'wab/impl/exprs/regex'

require 'wab/impl/exprs/and'
require 'wab/impl/exprs/or'
require 'wab/impl/exprs/not'

require 'wab/impl/expr_parser'
