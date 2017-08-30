#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

require 'wab'
require 'wab/impl'

class TestExprRegex < ImplTest

  def test_regex_native
    x = ::WAB::Impl::Regex.new('str', '^a *.')
    assert_equal(['REGEX', 'str', '^a *.'], x.native, 'REGEX native mismatch')
  end

  def test_regex_int
    d = make_sample_data()
    x = ::WAB::Impl::Regex.new('str', '^a .*')
    assert(x.eval(d), 'checking REGEX match with string arg')

    x = ::WAB::Impl::Regex.new('str', '^x .*')
    refute(x.eval(d), 'checking REGEX mismatch with string arg')

    x = ::WAB::Impl::Regex.new('num', 8)
    refute(x.eval(d), 'checking REGEX mismatch with an integer arg')
  end

  # TBD more tests for each type, Float, boolean, String, URI, UUID, Time, BigDecimal, nil

end # TestExprRegex
