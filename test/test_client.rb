#!/usr/bin/env ruby

$LOAD_PATH << __dir__
$LOAD_PATH << File.expand_path('../lib', __dir__)

require 'minitest'
require 'minitest/autorun'
require 'fileutils'
require 'open3'

require 'wab'

class TestClient < Minitest::Test

  def setup
    FileUtils.remove_dir("#{__dir__}/client_test/data", true)
    _, _, wt = Open3.popen2e("#{__dir__}/../bin/wabur", '-I', "#{__dir__}/../lib", '-c', "#{__dir__}/client_test/wabur.conf")
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
    Process.wait
  rescue
    # ignore
  end

  # Test a simple create, read, and delete. Leaving the state of the server
  # unchanged.
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
  end

  # TBD create with query, verify error on match, basically run same twice
  # TBD update with ref
  # TBD update with query, need multiple creates, use dlete with no query
  # TBD delete with query, not ref
  # TBD read with query
  # TBD tql

end
