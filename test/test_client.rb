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

  def run_wabur(port)
    store_dir = "#{__dir__}/client_test/data#{port}"
    FileUtils.remove_dir(store_dir, true)
    _, @out, wt = Open3.popen2e("ruby", "#{__dir__}/../bin/wabur", '-I', "#{__dir__}/../lib", '-c', "#{__dir__}/client_test/wabur.conf", '--http.port', port.to_s, '--store.dir', store_dir)
    20.times {
      begin
        Net::HTTP.get_response(URI("http://localhost:#{port}"))
        break
      rescue Exception => e
        sleep(0.1)
      end
    }
    wt.pid
  end
  
  def shutdown_wabur(pid)
    Process.kill('HUP', pid)
    # Uncomment to get verbose output from the server.
    #puts @out.read
    Process.wait
  rescue
    # ignore
  end

  def test_simple
    port = 6371
    pid = run_wabur(port)
    client = WAB::Client.new('localhost', port)
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

    ensure
    shutdown_wabur(pid)
  end

  def test_types
    port = 6372
    pid = run_wabur(port)
    client = WAB::Client.new('localhost', port)
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

    ensure
    shutdown_wabur(pid)
  end

  def test_create_query
    port = 6373
    pid = run_wabur(port)
    client = WAB::Client.new('localhost', port)

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

    ensure
    shutdown_wabur(pid)
  end

  def test_delete_all
    port = 6374
    pid = run_wabur(port)
    client = WAB::Client.new('localhost', port)
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

    ensure
    shutdown_wabur(pid)
  end

  def test_update_ref
    port = 6375
    pid = run_wabur(port)
    client = WAB::Client.new('localhost', port)

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

    ensure
    shutdown_wabur(pid)
  end

  def test_update_query
    port = 6376
    pid = run_wabur(port)
    client = WAB::Client.new('localhost', port)
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

    ensure
    shutdown_wabur(pid)
  end

  def test_delete_query
    port = 6377
    pid = run_wabur(port)
    client = WAB::Client.new('localhost', port)
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

    ensure
    shutdown_wabur(pid)
  end

  def test_read_query
    port = 6378
    pid = run_wabur(port)
    client = WAB::Client.new('localhost', port)
    3.times { |i|
      result = client.create({kind: 'Test', value: i})
      assert_equal(0, result[:code], "create #{i} result code mismatch")
    }

    result = client.read('Test', {value: 1})
    assert_equal(0, result[:code], 'read result code mismatch')
    assert_equal(1, result[:results].length, 'read wrong length')

    result = client.delete('Test')
    assert_equal(0, result[:code], 'delete result code mismatch')

    ensure
    shutdown_wabur(pid)
  end

  def test_tql
    port = 6379
    pid = run_wabur(port)
    client = WAB::Client.new('localhost', port)
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

    ensure
    shutdown_wabur(pid)
  end

end

