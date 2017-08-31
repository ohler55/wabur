#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

require 'wab/impl/expr_parser'

require 'test_expr_between'
require 'test_expr_eq'
require 'test_expr_gt'
require 'test_expr_gte'
require 'test_expr_has'
require 'test_expr_in'
require 'test_expr_lt'
require 'test_expr_lte'
require 'test_expr_regex'

require 'test_expr_not'
require 'test_expr_and'
require 'test_expr_or'

class TestExpr < TestImpl

  def test_expr_parser_parse
    natives = [
               ['EQ', 'num', 7],
               ['AND', ['HAS', 'str'], ['EQ', 'num', 7]],
              ]
    natives.each { |n|
      x = ::WAB::Impl::ExprParser.parse(n)
      assert_equal(n, x.native, "parsed failed for #{n}")
    }
  end

end # TestExpr
