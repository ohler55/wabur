#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

class GteTest < Minitest::Test

  def setup
    @shell = ::WAB::Impl::Shell.new({})
  end

  def test_gte_native
    x = ::WAB::Impl::Gte.new('num', 3)
    assert_equal(['GTE', 'num', 3], x.native, 'GTE native mismatch')
  end

  def test_gte_int
    d = make_sample_data()
    x = ::WAB::Impl::Gte.new('num', 7)
    assert(x.eval(d), 'checking GTE match with an integer arg')

    x = ::WAB::Impl::Gte.new('num', 8)
    refute(x.eval(d), 'checking GTE mismatch with an integer arg')
  end

  # TBD more tests for each type, Float, boolean, String, URI, UUID, Time, BigDecimal, nil

end # GteTest
