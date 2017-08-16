#!/usr/bin/env ruby
# encoding: UTF-8

$: << __dir__
$: << File.join(File.dirname(File.expand_path(__dir__)), 'lib')

require 'minitest'
require 'minitest/autorun'
require 'net/http'

require 'oj'
require 'wab/impl'
require 'wab/io'

# This tests is used to test WAB Runners. The Runner should be started with
# the MirrorController class. The host and port must be the last argument on
# the command line when running the test.
#
# As an example:
#    runner_test.rb -v localhost:6363
#

$host, $port = ARGV[-1].split(':')
$port = $port.to_i

class RunnerTest < Minitest::Test

  # The Runner or rather it's storage is stateful so all steps in the test
  # must be made in order to keep the test self contained. Each step is a
  # separate function though.
  def test_runner_basics
    http = Net::HTTP.new($host, $port)

    # Delete all records to start with a clean database
    clear_records(http)
    ref = create_record(http)
    read_record(http, ref)
    list_records(http, ref)

    ref = update_record(http, ref)
    read_after_update(http, ref)

    delete_record(http, ref)
    read_after_delete(http, ref)
  end

  def clear_records(http)
    resp = http.send_request('DELETE', '/Article')
    # Response should be an OK with a JSON body.
    assert_equal(Net::HTTPOK, resp.class, 'response not an OK')
    reply = Oj.strict_load(resp.body, symbol_keys: true)
  end

  # Returns the reference of the created record.
  def create_record(http)
    json = %|{
    "kind": "Article",
    "title": "Sample",
    "text": "Just some random text."
}|
    resp = http.send_request('PUT', '/Article', json, { 'Content-Type' => 'application/json' })
    # Response should be an OK with a JSON body.
    assert_equal(Net::HTTPOK, resp.class, 'response not an OK')
    reply = Oj.strict_load(resp.body, symbol_keys: true)

    # Make sure the message has the correct fields and values.
    assert_equal(2, reply[:api], 'create reply :api member should be 2 (controller to view)')
    body = reply[:body]
    assert_equal(0, body[:code], 'create reply body.code should be 0 meaning no error')
    ref = body[:ref]
    refute_equal(nil, ref, 'create reply record reference can not be nil')
    refute_equal(0, ref, 'create reply record reference can not be 0')
    ref
  end

  def read_record(http, ref)
    resp = http.send_request('GET', "/Article/#{ref}")
    assert_equal(Net::HTTPOK, resp.class, 'response not an OK')
    reply = Oj.strict_load(resp.body, symbol_keys: true)

    # Make sure the message has the correct fields and values.
    assert_equal(2, reply[:api], 'read reply :api member should be 2 (controller to view)')
    body = reply[:body]
    assert_equal(0, body[:code], 'read reply body.code should be 0 meaning no error')
    results = body[:results]
    assert_equal(1, results.length, 'read reply body.results should contain exactly one member')
    record = results[0]
    assert_equal(ref, record[:id], 'read reply body.results[0].id should match the record reference')
    obj = record[:data]
    assert_equal('Article', obj[:kind], 'read reply obj.kind incorrect')
    assert_equal('Sample', obj[:title], 'read reply obj.title incorrect')
  end

  def list_records(http, ref)
    resp = http.send_request('GET', '/Article')
    assert_equal(Net::HTTPOK, resp.class, 'response not an OK')
    reply = Oj.strict_load(resp.body, symbol_keys: true)

    # Make sure the message has the correct fields and values.
    assert_equal(2, reply[:api], 'read reply :api member should be 2 (controller to view)')
    body = reply[:body]
    assert_equal(0, body[:code], 'read reply body.code should be 0 meaning no error')
    results = body[:results]
    assert_equal(1, results.length, 'read reply body.results should contain exactly one member')
    record = results[0]
    assert_equal(ref, record[:id], 'read reply body.results[0].id should match the record reference')
    obj = record[:data]
    assert_equal('Article', obj[:kind], 'read reply obj.kind incorrect')
    assert_equal('Sample', obj[:title], 'read reply obj.title incorrect')
  end

  # Returns the reference of the updated record. There is no requirement that
  # the reference will not change.
  def update_record(http, ref)
    json = %|{
    "kind": "Article",
    "title": "Sample",
    "text": "Updated text."
}|
    resp = http.send_request('POST', "/Article/#{ref}", json, { 'Content-Type' => 'application/json' })
    # Response should be an OK with a JSON body.
    assert_equal(Net::HTTPOK, resp.class, 'response not an OK')
    reply = Oj.strict_load(resp.body, symbol_keys: true)

    # Make sure the message has the correct fields and values.
    assert_equal(2, reply[:api], 'update reply :api member should be 2 (controller to view)')
    body = reply[:body]
    assert_equal(0, body[:code], 'update reply body.code should be 0 meaning no error')
    updated = body[:updated]
    assert_equal(1, updated.length, 'update reply body.updated should contain exactly one member')
    ref = updated[0]
    refute_equal(nil, ref, 'update reply record reference can not be nil')
    refute_equal(0, ref, 'update reply record reference can not be 0')
    ref
  end

  def read_after_update(http, ref)
    resp = http.send_request('GET', "/Article/#{ref}")
    assert_equal(Net::HTTPOK, resp.class, 'response not an OK')
    reply = Oj.strict_load(resp.body, symbol_keys: true)

    body = reply[:body]
    assert_equal(0, body[:code], 'read after update reply body.code should be 0 meaning no error')
    results = body[:results]
    assert_equal(1, results.length, 'read after update reply body.results should contain exactly one member')
    record = results[0]
    assert_equal(ref, record[:id], 'read after update reply body.results[0].id should match the record reference')
    obj = record[:data]
    assert_equal('Updated text.', obj[:text], 'read after update reply obj.text incorrect')
  end

  def delete_record(http, ref)
    resp = http.send_request('DELETE', "/Article/#{ref}")
    # Response should be an OK with a JSON body.
    assert_equal(Net::HTTPOK, resp.class, 'response not an OK')
    reply = Oj.strict_load(resp.body, symbol_keys: true)

    # Make sure the message has the correct fields and values.
    assert_equal(2, reply[:api], 'delete reply :api member should be 2 (controller to view)')
    body = reply[:body]
    assert_equal(0, body[:code], 'delete reply body.code should be 0 meaning no error')
    deleted = body[:deleted]
    assert_equal(1, deleted.length, 'delete reply body.deleted should contain exactly one member')
    ref = deleted[0]
    refute_equal(nil, ref, 'delete reply record reference can not be nil')
    refute_equal(0, ref, 'delete reply record reference can not be 0')
  end

  def read_after_delete(http, ref)
    resp = http.send_request('GET', "/Article/#{ref}")
    assert_equal(Net::HTTPOK, resp.class, 'response not an OK')
    reply = Oj.strict_load(resp.body, symbol_keys: true)

    body = reply[:body]
    assert_equal(0, body[:code], 'read after delete reply body.code should be 0 meaning no error')
    results = body[:results]
    assert_equal(0, results.length, 'read after delete reply body.results should contain no members')
  end


  # TBD test failure modes as well
  # TBD test multiple matches on update and delete
  # TBD test no matches on update and delete
  # TBD test queries

end # RunnerTest
