#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

class TestExprLte < TestImpl

  def test_lte_native
    x = WAB::Impl::Lte.new('num', 3)
    assert_equal(['LTE', 'num', 3], x.native, 'LTE native mismatch')
  end

  def test_lte_int
    d = make_sample_data()
    x = WAB::Impl::Lte.new('num', 7)
    assert(x.eval(d), 'checking LTE match with an integer arg')

    x = WAB::Impl::Lte.new('num', 6)
    refute(x.eval(d), 'checking LTE mismatch with an integer arg')
  end

  # TBD more tests for each type, Float, boolean, String, URI, UUID, Time, BigDecimal, nil

end # TestExprLte
