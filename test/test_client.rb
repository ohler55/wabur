#!/usr/bin/env ruby

$LOAD_PATH << __dir__
$LOAD_PATH << File.expand_path('../lib', __dir__)

require 'minitest'
require 'minitest/autorun'
require 'fileutils'
require 'open3'
require 'uri'

require 'wab'

class TestClient < Minitest::Test

  # All tests must leave the DB state of the server unchanged.

  def setup
    FileUtils.remove_dir("#{__dir__}/client_test/data", true)
    _, @out, wt = Open3.popen2e("ruby", "#{__dir__}/../bin/wabur", '-I', "#{__dir__}/../lib", '-c', "#{__dir__}/client_test/wabur.conf")
    @pid = wt.pid
    20.times {
      begin
        Net::HTTP.get_response(URI('http://localhost:6373'))
        break
      rescue Exception => e
        sleep(0.1)
      end
    }
  end
  
  def teardown
    Process.kill('HUP', @pid)
    #puts @out.read
    Process.wait
  rescue
    # ignore
  end

  def test_simple
    client = WAB::Client.new('localhost', 6373)
    result = client.create({kind: 'Test', value: 123})
    assert_equal(0, result[:code], 'create result code mismatch')
    ref = result[:ref]

    result = client.read('Test', ref)
    assert_equal(0, result[:code], 'read result code mismatch')
    assert_equal(1, result[:results].length, 'read result wrong length')
    rec = result[:results][0]
    assert_equal('Test', rec[:data][:kind], 'read kind mismatch')
    assert_equal(123, rec[:data][:value], 'read value mismatch')

    result = client.delete('Test', ref)
    assert_equal(0, result[:code], 'delete result code mismatch')
    assert_equal([ref], result[:deleted], 'delete list mismatch')

    result = client.read('Test', ref)
    assert_equal(0, result[:code], 'read after delete result code mismatch')
    assert_equal(0, result[:results].length, 'read after delete result wrong length')
  end

  def test_types
    client = WAB::Client.new('localhost', 6373)
    t = Time.now
    uuid = WAB::UUID.new('b0ca922d-372e-41f4-8fea-47d880188ba3')
    uri = URI("http://wab.systems/sample")
    obj = {
      kind: 'Test',
      num: 123,
      bool: true,
      null: nil,
      str: "string",
      dub: 1.23,
      time: t,
      uuid: uuid,
      uri: uri
    }
    result = client.create(obj)
    assert_equal(0, result[:code], 'create result code mismatch')
    ref = result[:ref]

    result = client.read('Test', ref)
    assert_equal(0, result[:code], 'read result code mismatch')
    assert_equal(1, result[:results].length, 'read result wrong length')
    rec = result[:results][0]
    assert_equal('Test', rec[:data][:kind], 'read kind mismatch')
    assert_equal(obj, rec[:data], 'read data mismatch')

    result = client.delete('Test', ref)
    assert_equal(0, result[:code], 'delete result code mismatch')
    assert_equal([ref], result[:deleted], 'delete list mismatch')
  end

  def test_create_query
    client = WAB::Client.new('localhost', 6373)

    result = client.create({kind: 'Test', value: 123}, 'Test', {value: 123})
    assert_equal(0, result[:code], 'create result code mismatch')
    ref = result[:ref]

    result = client.read('Test', ref)
    assert_equal(0, result[:code], 'read result code mismatch')
    assert_equal(1, result[:results].length, 'read result wrong length')

    # Same again should fail.
    assert_raises('should fail to create a duplicate') {
      result = client.create({kind: 'Test', value: 123}, 'Test', {value: 123})
    }

    result = client.delete('Test', ref)
    assert_equal(0, result[:code], 'delete result code mismatch')
    assert_equal([ref], result[:deleted], 'delete list mismatch')
  end

  def test_delete_all
    client = WAB::Client.new('localhost', 6373)
    refs = []
    3.times { |i|
      result = client.create({kind: 'Test', value: i})
      assert_equal(0, result[:code], "create #{i} result code mismatch")
      refs << result[:ref]
    }

    result = client.read('Test')
    assert_equal(0, result[:code], 'read result code mismatch')
    assert_equal(3, result[:results].length, 'read result wrong length')

    result = client.delete('Test')
    assert_equal(0, result[:code], 'delete result code mismatch')
    assert_equal(3, result[:deleted].length, 'delete list length mismatch')
  end

  def test_update_ref
    client = WAB::Client.new('localhost', 6373)

    result = client.create({kind: 'Test', value: 123})
    assert_equal(0, result[:code], 'create result code mismatch')
    ref = result[:ref]

    result = client.update('Test', {kind: 'Test', value: 321}, ref)
    assert_equal(0, result[:code], 'create result code mismatch')
    
    result = client.read('Test', ref)
    assert_equal(0, result[:code], 'read result code mismatch')
    assert_equal(1, result[:results].length, 'read result wrong length')
    rec = result[:results][0]
    assert_equal('Test', rec[:data][:kind], 'read kind mismatch')
    assert_equal(321, rec[:data][:value], 'read value mismatch')

    result = client.delete('Test', ref)
    assert_equal(0, result[:code], 'delete result code mismatch')
    assert_equal([ref], result[:deleted], 'delete list mismatch')
  end

  def test_update_query
    client = WAB::Client.new('localhost', 6373)
    refs = []
    3.times { |i|
      result = client.create({kind: 'Test', value: i})
      assert_equal(0, result[:code], "create #{i} result code mismatch")
      refs << result[:ref]
    }

    result = client.update('Test', {kind: 'Test', value: 111}, {value: 1})
    assert_equal(0, result[:code], 'create result code mismatch')
    assert_equal(1, result[:updated].length, 'updated wrong length')

    result = client.read('Test', refs[1])
    assert_equal(0, result[:code], 'read result code mismatch')
    assert_equal(1, result[:results].length, 'read result wrong length')
    rec = result[:results][0]
    assert_equal('Test', rec[:data][:kind], 'read kind mismatch')
    assert_equal(111, rec[:data][:value], 'read value mismatch')

    result = client.delete('Test')
    assert_equal(0, result[:code], 'delete result code mismatch')
  end

  def test_delete_query
    client = WAB::Client.new('localhost', 6373)
    refs = []
    3.times { |i|
      result = client.create({kind: 'Test', value: i})
      assert_equal(0, result[:code], "create #{i} result code mismatch")
      refs << result[:ref]
    }

    result = client.delete('Test', {value: 1})
    assert_equal(0, result[:code], 'create result code mismatch')
    assert_equal(1, result[:deleted].length, 'updated wrong length')

    result = client.read('Test')
    assert_equal(0, result[:code], 'read result code mismatch')
    assert_equal(2, result[:results].length, 'read result wrong length')

    result = client.delete('Test')
    assert_equal(0, result[:code], 'delete result code mismatch')
  end

  def test_read_query
    client = WAB::Client.new('localhost', 6373)
    3.times { |i|
      result = client.create({kind: 'Test', value: i})
      assert_equal(0, result[:code], "create #{i} result code mismatch")
    }

    result = client.read('Test', {value: 1})
    assert_equal(0, result[:code], 'read result code mismatch')
    assert_equal(1, result[:results].length, 'read wrong length')

    result = client.delete('Test')
    assert_equal(0, result[:code], 'delete result code mismatch')
  end

  def test_tql
    client = WAB::Client.new('localhost', 6373)
    3.times { |i|
      result = client.create({kind: 'Test', value: i})
      assert_equal(0, result[:code], "create #{i} result code mismatch")
    }

    result = client.find({
                           where: ['LT', 'value', 2],
                           select: '$ref'
                         })

    assert_equal(0, result[:code], 'read result code mismatch')
    assert_equal(2, result[:results].length, 'results wrong length')

    result = client.delete('Test')
    assert_equal(0, result[:code], 'delete result code mismatch')
  end

end
