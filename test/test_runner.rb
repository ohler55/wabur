#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

require 'net/http'
require 'oj'

require 'wab/impl'
require 'wab/io'

# -----------------------------------------------------------------------------
# This is to verify that WAB-Runners behave as expected.
#
# Requirements:
#   - The Runner (e.g. OpO daemon) should be started with the MirrorController
#     class.
#   - The host and port must be the last argument on the command line when
#     invoking the test.
#
# Example usage:
#    runner_test.rb localhost:6363
# -----------------------------------------------------------------------------

raise ArgumentError, 'Host and port not supplied.' if ARGV.empty?

$host, $port = ARGV[-1].split(':')
$port = $port.to_i

class TestRunner < Minitest::Test

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
    resp = http.send_request('DELETE', '/v1/Article')
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
    resp = http.send_request('PUT', '/v1/Article', json, { 'Content-Type' => 'application/json' })
    # Response should be an OK with a JSON body.
    assert_equal(Net::HTTPOK, resp.class, 'response not an OK')
    reply = Oj.strict_load(resp.body, symbol_keys: true)

    # Make sure the message has the correct fields and values.
    assert_equal(0, reply[:code], 'create reply.code should be 0 meaning no error')
    ref = reply[:ref]
    refute_equal(nil, ref, 'create reply record reference can not be nil')
    refute_equal(0, ref, 'create reply record reference can not be 0')
    ref
  end

  def read_record(http, ref)
    resp = http.send_request('GET', "/v1/Article/#{ref}")
    assert_equal(Net::HTTPOK, resp.class, 'response not an OK')
    reply = Oj.strict_load(resp.body, symbol_keys: true)

    # Make sure the message has the correct fields and values.
    assert_equal(0, reply[:code], 'read reply.code should be 0 meaning no error')
    results = reply[:results]
    assert_equal(1, results.length, 'read reply.results should contain exactly one member')
    record = results[0]
    assert_equal(ref, record[:id], 'read reply.results[0].id should match the record reference')
    obj = record[:data]
    assert_equal('Article', obj[:kind], 'read reply obj.kind incorrect')
    assert_equal('Sample', obj[:title], 'read reply obj.title incorrect')
  end

  def list_records(http, ref)
    resp = http.send_request('GET', '/v1/Article')
    assert_equal(Net::HTTPOK, resp.class, 'response not an OK')
    reply = Oj.strict_load(resp.body, symbol_keys: true)

    # Make sure the message has the correct fields and values.
    assert_equal(0, reply[:code], 'read reply.code should be 0 meaning no error')
    results = reply[:results]
    assert_equal(1, results.length, 'read reply.results should contain exactly one member')
    record = results[0]
    assert_equal(ref, record[:id], 'read reply.results[0].id should match the record reference')
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
    resp = http.send_request('POST', "/v1/Article/#{ref}", json, { 'Content-Type' => 'application/json' })
    # Response should be an OK with a JSON body.
    assert_equal(Net::HTTPOK, resp.class, 'response not an OK')
    reply = Oj.strict_load(resp.body, symbol_keys: true)

    # Make sure the message has the correct fields and values.
    assert_equal(0, reply[:code], 'update reply.code should be 0 meaning no error')
    updated = reply[:updated]
    assert_equal(1, updated.length, 'update reply.updated should contain exactly one member')
    ref = updated[0]
    refute_equal(nil, ref, 'update reply record reference can not be nil')
    refute_equal(0, ref, 'update reply record reference can not be 0')
    ref
  end

  def read_after_update(http, ref)
    resp = http.send_request('GET', "/v1/Article/#{ref}")
    assert_equal(Net::HTTPOK, resp.class, 'response not an OK')
    reply = Oj.strict_load(resp.body, symbol_keys: true)

    assert_equal(0, reply[:code], 'read after update reply.code should be 0 meaning no error')
    results = reply[:results]
    assert_equal(1, results.length, 'read after update reply.results should contain exactly one member')
    record = results[0]
    assert_equal(ref, record[:id], 'read after update reply.results[0].id should match the record reference')
    obj = record[:data]
    assert_equal('Updated text.', obj[:text], 'read after update reply obj.text incorrect')
  end

  def delete_record(http, ref)
    resp = http.send_request('DELETE', "/v1/Article/#{ref}")
    # Response should be an OK with a JSON body.
    assert_equal(Net::HTTPOK, resp.class, 'response not an OK')
    reply = Oj.strict_load(resp.body, symbol_keys: true)

    # Make sure the message has the correct fields and values.
    assert_equal(0, reply[:code], 'delete reply.code should be 0 meaning no error')
    deleted = reply[:deleted]
    assert_equal(1, deleted.length, 'delete reply.deleted should contain exactly one member')
    ref = deleted[0]
    refute_equal(nil, ref, 'delete reply record reference can not be nil')
    refute_equal(0, ref, 'delete reply record reference can not be 0')
  end

  def read_after_delete(http, ref)
    resp = http.send_request('GET', "/v1/Article/#{ref}")
    assert_equal(Net::HTTPOK, resp.class, 'response not an OK')
    reply = Oj.strict_load(resp.body, symbol_keys: true)

    assert_equal(0, reply[:code], 'read after delete reply.code should be 0 meaning no error')
    results = reply[:results]
    assert_equal(0, results.length, 'read after delete reply.results should contain no members')
  end


  # TBD test failure modes as well
  # TBD test multiple matches on update and delete
  # TBD test no matches on update and delete
  # TBD test queries

end # TestRunner
