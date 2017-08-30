#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

class TestExprIn < ImplTest

  def test_in_native
    x = ::WAB::Impl::In.new('num', 3, 4, 5)
    assert_equal(['IN', 'num', 3, 4, 5], x.native, 'IN native mismatch')
  end

  def test_in_int
    d = make_sample_data()
    x = ::WAB::Impl::In.new('num', 1, 3, 5, 7, 11)
    assert(x.eval(d), 'checking IN match with an integer arg')

    x = ::WAB::Impl::In.new('num', 0, 2, 4, 6, 8, 10)
    refute(x.eval(d), 'checking IN mismatch with an integer arg')
  end

  # TBD more tests for each type, Float, boolean, String, URI, UUID, Time, BigDecimal, nil

end # TestExprIn
