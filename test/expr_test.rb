#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

require 'wab/impl/exprparse'

require 'between_test'
require 'eq_test'
require 'gt_test'
require 'gte_test'
require 'has_test'
require 'in_test'
require 'lt_test'
require 'lte_test'
require 'regex_test'

require 'not_test'
require 'and_test'
require 'or_test'

class ExprTest < Minitest::Test

  def setup
    @shell = ::WAB::Impl::Shell.new({})
  end

  def test_expr_parse
    natives = [
               ['EQ', 'num', 7],
               ['AND', ['HAS', 'str'], ['EQ', 'num', 7]],
              ]
    natives.each { |n|
      x = ::WAB::Impl::Expr.parse(n)
      assert_equal(n, x.native, "parsed failed for #{n}")
    }
  end

end # ExprTest
