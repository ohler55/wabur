#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

class TestExprNot < ImplTest

  def test_not_native
    x = ::WAB::Impl::Not.new(::WAB::Impl::Eq.new('num', 7))
    assert_equal(['NOT', ['EQ', 'num', 7]], x.native, 'NOT native mismatch')
  end

  def test_not
    d = make_sample_data()
    x = ::WAB::Impl::Not.new(::WAB::Impl::Eq.new('num', 8))
    assert(x.eval(d), 'checking NOT match')

    x = ::WAB::Impl::Not.new(::WAB::Impl::Eq.new('num', 7))
    refute(x.eval(d), 'checking NOT mismatch')
  end

end # TestExprNot
