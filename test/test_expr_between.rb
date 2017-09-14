#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

class TestExprBetween < TestImpl

  def test_between_native
    x = WAB::Impl::Between.new('num', 3, 7, true, false)
    assert_equal(['BETWEEN', 'num', 3, 7, true, false], x.native, 'BETWEEN native mismatch')
  end

  def test_between_int
    d = make_sample_data
    x = WAB::Impl::Between.new('num', 7, 10)
    assert(x.eval(d), 'checking BETWEEN match with an integer arg')

    x = WAB::Impl::Between.new('num', 8, 10)
    refute(x.eval(d), 'checking BETWEEN mismatch with an integer arg')

    x = WAB::Impl::Between.new('num', 5, 7)
    assert(x.eval(d), 'checking BETWEEN match with an integer arg')

    x = WAB::Impl::Between.new('num', 5, 6)
    refute(x.eval(d), 'checking BETWEEN mismatch with an integer arg')

    # exclusive of min
    x = WAB::Impl::Between.new('num', 6, 10, false)
    assert(x.eval(d), 'checking BETWEEN match with an integer arg')

    x = WAB::Impl::Between.new('num', 7, 10, false)
    refute(x.eval(d), 'checking BETWEEN mismatch with an integer arg')

    x = WAB::Impl::Between.new('num', 5, 8, false, false)
    assert(x.eval(d), 'checking BETWEEN match with an integer arg')

    x = WAB::Impl::Between.new('num', 5, 7, false, false)
    refute(x.eval(d), 'checking BETWEEN mismatch with an integer arg')
  end

  # TBD more tests for each type, Float, boolean, String, URI, UUID, Time, BigDecimal, nil

end # TestExprBetween
