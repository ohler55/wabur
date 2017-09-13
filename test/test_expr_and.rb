#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

class TestExprAnd < TestImpl

  def test_and_native
    x = WAB::Impl::And.new(WAB::Impl::Has.new('num'), WAB::Impl::Eq.new('num', 7))
    assert_equal(['AND', ['HAS', 'num'], ['EQ', 'num', 7]], x.native, 'AND native mismatch')
  end

  def test_and
    d = make_sample_data()
    x = WAB::Impl::And.new(WAB::Impl::Has.new('num'), WAB::Impl::Eq.new('num', 7))
    assert(x.eval(d), 'checking AND match')

    x = WAB::Impl::And.new(WAB::Impl::Has.new('num'), WAB::Impl::Eq.new('num', 8))
    refute(x.eval(d), 'checking AND mismatch')
  end

  # TBD tests with no args, with one, with more than 2, test using append_arg

end # TestExprAnd
