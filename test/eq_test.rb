#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

class EqTest < ImplTest

  def test_eq_native
    x = ::WAB::Impl::Eq.new('num', 7)
    assert_equal(['EQ', 'num', 7], x.native, 'EQ native mismatch')
  end

  def test_eq_int
    d = make_sample_data()
    x = ::WAB::Impl::Eq.new('num', 7)
    assert(x.eval(d), 'checking EQ match with an integer arg')

    x = ::WAB::Impl::Eq.new('num', 17)
    refute(x.eval(d), 'checking EQ mismatch with an integer arg')
  end

  # TBD more tests for each type, Float, boolean, String, URI, UUID, Time, BigDecimal, nil

end # EqTest
