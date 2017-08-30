#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

class TestExprHas < ImplTest

  def test_has_int
    d = make_sample_data()
    x = ::WAB::Impl::Has.new('num')
    assert(x.eval(d), 'checking HAS match')

    x = ::WAB::Impl::Has.new('none')
    refute(x.eval(d), 'checking HAS mismatch')
  end

  # TBD test with path as an array, tests with symbol path
  
end # TestExprHas
