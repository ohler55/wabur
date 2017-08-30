#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

require 'wab'
require 'wab/impl'

class DataTest < ImplTest

  class ToHash
    def initialize(x, y)
      @h = {x: x, y: y }
    end

    def to_h
      @h
    end
  end

  def test_json
    d = make_sample_data()
    # downcase to match Ruby 2.3 and 2.4 which encode BigDecimal differently.
    assert_equal(%|{
  "boo":true,
  "n":null,
  "num":7,
  "float":7.654,
  "str":"a string",
  "t":"2017-01-05t15:04:33.123456789z",
  "big":0.6321e2,
  "uri":"http://opo.technology/sample",
  "uuid":"b0ca922d-372e-41f4-8fea-47d880188ba3",
  "a":[],
  "h":{}
}
|, d.json(2).downcase)
  end

  def test_validate_keys
    assert_raises(WAB::KeyError) { d = @shell.data({ 'a' => 1}) }
    assert_raises(WAB::TypeError) { d = @shell.data('text') }
  end

  def test_repair_keys
    d = @shell.data({ 'a' => 1}, true)
    assert_equal({a:1}, d.native, "data not repaired")
  end

  def test_validate_non_hash_array
    assert_raises() { d = @shell.data(123) }
  end

  def test_fix_non_hash_array
    # can not fix this one
    assert_raises() { d = @shell.data(123, true) }
  end

  def test_validate_object
    assert_raises() { d = @shell.data({a: 1..3}) }
  end

  def test_repair_to_s_object
    d = @shell.data({a: 1..3}, true)
    assert_equal({a:'1..3'}, d.native, "data not repaired")
  end

  def test_repair_to_h_object
    d = @shell.data(ToHash.new(1, 2), true)
    assert_equal({x:1,y:2}, d.native, "data not repaired")
  end

  def test_hash_get
    d = @shell.data({a: 1, b: 2})
    assert_equal(2, d.get('b'), "failed to get 'b'")
    assert_equal(2, d.get([:b]), "failed to get [:b]")
    assert_equal(1, d.get(['a']), "failed to get ['a']")
    assert_nil(d.get(['d']), "failed to get ['d']")
  end

  def test_array_get
    d = @shell.data(['a', 'b', 'c'])
    assert_equal('b', d.get('1'), "failed to get '1'")
    assert_equal('c', d.get(['2']), "failed to get ['2']")
    assert_equal('b', d.get([1]), "failed to get [1]")
    assert_equal('a', d.get([0]), "failed to get [0]")
    assert_equal('c', d.get([-1]), "failed to get [-1]")
    assert_nil(d.get([4]), "failed to get [4]")
  end

  def test_get_mixed
    d = @shell.data({a: 1, b: ['a', 'b', { c: 3}]})
    assert_equal(3, d.get('b.2.c'), "failed to get 'b.2.c'")
    assert_equal(3, d.get([:b, 2, 'c']), "failed to get [b, 2, c]")
  end

  def test_hash_set
    d = @shell.data({a: 1})
    d.set('b', 2)
    d.set([:c], 3)
    d.set([:d], 1..4, true)
    assert_raises() { d.set([:e], 1..5) }
    assert_equal(%|{
  "a":1,
  "b":2,
  "c":3,
  "d":"1..4"
}
|, d.json(2))
    # replace existing
    d.set([:c], -3)
    assert_equal(%|{
  "a":1,
  "b":2,
  "c":-3,
  "d":"1..4"
}
|, d.json(2))
  end

  def test_array_set
    d = @shell.data(['x'])
    d.set([2], 'd')
    assert_equal(%|["x",null,"d"]|, d.json(), "after d")
    d.set([1], 'c')
    assert_equal(%|["x","c","d"]|, d.json(), "after c")
    d.set([0], 'y')
    assert_equal(%|["y","c","d"]|, d.json(), "after y")
    d.set([-3], 'b')
    assert_equal(%|["b","c","d"]|, d.json(), "after b")
    d.set([-4], 'a')
    assert_equal(%|["a","b","c","d"]|, d.json(), "after a")
  end

  def test_set_mixed
    d = @shell.data({a: 1, b: ['a', 'b', { c: 3}]})
    d.set('b.2', 'c')
    assert_equal(%|{"a":1,"b":["a","b","c"]}|, d.json())
  end

  def test_hash_length
    d = @shell.data({a: 1, b: 2})
    assert_equal(2, d.length())
  end

  def test_array_length
    d = @shell.data(['a', 'b', 'c'])
    assert_equal(3, d.length())
  end

  def test_mixed_length
    d = @shell.data({a: 1, b: ['a', 'b', { c: 3}]})
    assert_equal(2, d.length())
  end

  def test_empty_leaf_count
    d = @shell.data()
    assert_equal(0, d.leaf_count())
  end

  def test_hash_leaf_count
    d = @shell.data({a: 1, b: 2, c:{}})
    assert_equal(2, d.leaf_count())
  end

  def test_array_leaf_count
    d = @shell.data(['a', 'b', 'c', []])
    assert_equal(3, d.leaf_count())
  end

  def test_mixed_leaf_count
    d = @shell.data({a: 1, b: ['a', 'b', { c: 3}]})
    assert_equal(4, d.leaf_count())
  end

  def test_empty_size
    d = @shell.data()
    assert_equal(1, d.size())
  end

  def test_hash_size
    d = @shell.data({a: 1, b: 2, c:{}})
    assert_equal(4, d.size())
  end

  def test_array_size
    d = @shell.data(['a', 'b', 'c', []])
    assert_equal(5, d.size())
  end

  def test_mixed_size
    d = @shell.data({a: 1, b: ['a', 'b', { c: 3}]})
    assert_equal(7, d.size())
  end

  def test_each
    d = @shell.data({a: 1, b: ['a', 'b', { c: 3}]})
    paths = []
    values = []
    d.each { |p, v|
      paths << p
      values << v
    }
    assert_equal([[], [:a], [:b], [:b, 0], [:b, 1], [:b, 2], [:b, 2, :c]], paths, "paths mismatch")
    assert_equal([{:a=>1, :b=>["a", "b", {:c=>3}]}, 1, ["a", "b", {:c=>3}], "a", "b", {:c=>3}, 3], values, "values mismatch")
  end

  def test_each_leaf
    d = @shell.data({a: 1, b: ['a', 'b', { c: 3}]})
    paths = []
    values = []
    d.each_leaf { |p, v|
      paths << p
      values << v
    }
    assert_equal([[:a], [:b, 0], [:b, 1], [:b, 2, :c]], paths, "paths mismatch")
    assert_equal([1, "a", "b", 3], values, "values mismatch")
  end

  def test_eql
    d = @shell.data({a: 1, b: ['a', 'b', { c: 3}]})
    d2 = @shell.data({a: 1, b: ['a', 'b', { c: 3}]})
    d3 = @shell.data({a: 1, b: ['a', 'b', { d: 3}]})
    d4 = @shell.data({a: 1, b: ['a', 'b', { c: 4}]})

    assert(d == d2, "same keys and values should be eql")
    assert(!(d == d3), "same values different keys should not be eql")
    assert(!(d == d4), "same keys different values should not be eql")
  end

  def test_clone
    d = @shell.data({a: 1, b: ['a', 'b', { c: 3}]})
    c = d.clone
    assert(d == c)
  end

  def test_detect
    d = @shell.data({
                      t: '2017-01-05T15:04:33.123456789Z',
                      uris: ['http://opo.technology/sample'],
                      sub:{
                        uuid: 'b0ca922d-372e-41f4-8fea-47d880188ba3'
                      }
                    })
    d.detect()
    assert_equal(%|{
  "t":"2017-01-05t15:04:33.123456789z",
  "uris":[
    "http://opo.technology/sample"
  ],
  "sub":{
    "uuid":"b0ca922d-372e-41f4-8fea-47d880188ba3"
  }
}
|, d.json(2).downcase)
    
    assert_equal(Time, d.get('t').class)
    assert_equal(::URI::HTTP, d.get('uris.0').class)
    assert_equal(::WAB::UUID, d.get('sub.uuid').class)
  end

end # DataTest
