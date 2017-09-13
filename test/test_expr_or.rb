#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

class TestExprOr < TestImpl

  def test_or_native
    x = WAB::Impl::Or.new(WAB::Impl::Has.new('num'), WAB::Impl::Eq.new('num', 7))
    assert_equal(['OR', ['HAS', 'num'], ['EQ', 'num', 7]], x.native, 'OR native mismatch')
  end

  def test_or
    d = make_sample_data()
    x = WAB::Impl::Or.new(WAB::Impl::Has.new('str'), WAB::Impl::Eq.new('num', 8))
    assert(x.eval(d), 'checking OR match')

    x = WAB::Impl::Or.new(WAB::Impl::Has.new('none'), WAB::Impl::Eq.new('num', 8))
    refute(x.eval(d), 'checking OR mismatch')
  end

  # TBD tests with no args, with one, with more than 2, test using append_arg

end # TestExprOr
