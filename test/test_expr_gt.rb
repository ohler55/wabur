#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

class TestExprGt < TestImpl

  def test_gt_native
    x = WAB::Impl::Gt.new('num', 3)
    assert_equal(['GT', 'num', 3], x.native, 'GT native mismatch')
  end

  def test_gt_int
    d = make_sample_data
    x = WAB::Impl::Gt.new('num', 6)
    assert(x.eval(d), 'checking GT match with an integer arg')

    x = WAB::Impl::Gt.new('num', 7)
    refute(x.eval(d), 'checking GT mismatch with an integer arg')
  end

  # TBD more tests for each type, Float, boolean, String, URI, UUID, Time, BigDecimal, nil

end # TestExprGt
