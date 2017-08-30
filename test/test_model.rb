#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

require 'wab/impl/model'

class TestModel < TestImpl

  def test_model_create
    # nil arg indicates don't save to disk
    model = ::WAB::Impl::Model.new(nil)
    tql = {
      rid: 12345,
      insert: {
        kind: 'Person',
        name: 'Peter',
        age: 63
      }
    }
    result = model.query(tql)
    assert_equal(0, result[:code], 'expected a 0 result code')
    assert_equal(12345, result[:rid], 'expected correct rid')
    ref = result[:ref]
    # get and verify object was stored.
    obj = model.get(ref)

    assert_equal({kind: 'Person', name: 'Peter', age: 63}, obj.native, 'obj get mismatch')
  end

end # TestModel
