#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

class TestExprLt < TestImpl

  def test_lt_native
    x = WAB::Impl::Lt.new('num', 3)
    assert_equal(['LT', 'num', 3], x.native, 'LT native mismatch')
  end

  def test_lt_int
    d = make_sample_data()
    x = WAB::Impl::Lt.new('num', 8)
    assert(x.eval(d), 'checking LT match with an integer arg')

    x = WAB::Impl::Lt.new('num', 7)
    refute(x.eval(d), 'checking LT mismatch with an integer arg')
  end

  # TBD more tests for each type, Float, boolean, String, URI, UUID, Time, BigDecimal, nil

end # TestExprLt
