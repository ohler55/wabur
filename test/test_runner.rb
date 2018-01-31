#!/usr/bin/env ruby

require_relative 'helper'

require 'net/http'
require 'oj'

require 'wab/impl'
require 'wab/io'

# -----------------------------------------------------------------------------
# This is to verify that WAB-Runners behave as expected.
#
# Requirements:
#   - A Runner such as wabur or opo-rub.
#   - The Runner should be started with the MirrorController class in
#     mirror_controller.rb
#   - The configuration files for the wabur and opo-rub Runners are in the
#     runner directory.
#
# Start the runner using local code (in a separate terminal):
#    ../bin/wabur -I ../lib -I . -c runner/wabur.conf
# Run the test:
#    runner_test.rb localhost:6363
# -----------------------------------------------------------------------------

raise ArgumentError, 'Host and port not supplied.' if ARGV.empty?

$host, $port = ARGV[-1].split(':')
$port = $port.to_i

class TestRunner < Minitest::Test

  def setup
    @client = WAB::Client.new($host, $port)
    # Delete all records to start with a clean database
    clear_records(@client)
  end

  # The Runner or rather it's storage is stateful so all steps in the test
  # must be made in order to keep the test self contained. Each step is a
  # separate function though.
  def test_runner_using_refs
    ref = create_records(@client)
    get_record(@client, ref)
    update_record(@client, ref)
    delete_record(@client, ref)
  end

  def test_runner_using_queries
    ref = create_records(@client)

    read_record(@client, ref)
    list_records(@client)
    query_records(@client)
    update_query(@client)
    delete_query(@client)
  end

  def test_runner_missing
    create_records(@client)

    puts "  --- read missing" if $VERBOSE
    result = @client.read('Article', {title: 'Missing'})
    check_result_code(result)
    assert_equal(0, result[:results].length, 'read results should be empty')

    puts "  --- update missing" if $VERBOSE
    result = @client.update('Article', {kind: 'Article'}, {title: 'Missing'})
    check_result_code(result)
    assert_equal(0, result[:updated].length, 'updated should be empty')
    
    puts "  --- delete missing" if $VERBOSE
    result = @client.delete('Article', {title: 'Missing'})
    check_result_code(result)
    assert_equal(0, result[:deleted].length, 'deleted should be empty')
  end

  def test_runner_duplicate
    create_records(@client)

    assert_raises('should fail to create an unsupported kind') {
      @client.create({
                      kind: 'Article',
                      title: 'Sample',
                      text: 'Different.'}, {title: 'Sample'})
    }
  end

  def test_runner_multi_match
    # create records twice so there are duplicates
    create_records(@client)
    create_records(@client)

    puts "  --- delete multi" if $VERBOSE
    result = @client.delete('Article', {title: 'Second'})
    check_result_code(result)
    assert_equal(2, result[:deleted].length, 'delete reply.deleted should contain exactly two member')

    result = @client.read('Article')
    check_result_code(result)
    assert_equal(4, result[:results].length, 'read reply.results should contain all member')
  end

  def test_runner_query
    10.times { |i|
      @client.create({kind: 'Article', title: "Article-#{i}", num: i})
    }

    check_query(@client, {where: ['EQ', 'num', 3], select: 'title'}, ['Article-3'])
    check_query(@client, {where: ['EQ', 'title', 'Article-4'], select: 'title'}, ['Article-4'])

    check_query(@client, {where: ['LT', 'num', 3], select: 'title'}, ['Article-0','Article-1','Article-2'])
    check_query(@client, {where: ['LTE', 'num', 2], select: 'title'}, ['Article-0','Article-1','Article-2'])

    check_query(@client, {where: ['GT', 'num', 7], select: 'title'}, ['Article-8','Article-9'])
    check_query(@client, {where: ['GTE', 'num', 7], select: 'title'}, ['Article-7','Article-8','Article-9'])

    check_query(@client, {where: ['BETWEEN', 'num', 5, 7], select: 'title'}, ['Article-5','Article-6','Article-7'])
    check_query(@client, {where: ['BETWEEN', 'num', 5, 7, false, false], select: 'title'}, ['Article-6'])
    check_query(@client, {where: ['BETWEEN', 'num', 5, 7, false, true], select: 'title'}, ['Article-6','Article-7'])
    check_query(@client, {where: ['BETWEEN', 'num', 5, 7, true, false], select: 'title'}, ['Article-5','Article-6'])

    check_query(@client, {where: ['IN', 'num', 1, 3, 5, 7], select: 'title'}, ['Article-1','Article-3','Article-5','Article-7'])

    check_query(@client, {where: ['OR', ['LT', 'num', 2], ['GT', 'num', 7]], select: 'title'}, ['Article-0','Article-1','Article-8','Article-9'])
    check_query(@client, {where: ['EQ', 'kind', 'Article'], filter: ['NOT', ['BETWEEN', 'num', 2, 7]], select: 'num'}, [0, 1, 8, 9])

    check_query(@client, {where: ['eq', 'kind', 'Article'], filter: ['eq', 'title', 'Article-3'], select: 'num'}, [3])
    check_query(@client, {where: ['eq', 'kind', 'Article'], filter: ['regex', 'title', 'A.*-[3,4,5]'], select: 'num'}, [3, 4, 5])

    check_query(@client, {where: ['and', ['LT', 'num', 5], ['GT', 'num', 2]], select: 'num'}, [3, 4])

    check_query(@client, {where: ['and', ['LT', 'num', 5], ['or', ['eq', 'num', 0], ['GT', 'num', 2]]], select: 'num'}, [0, 3, 4])
  end

  def tbd_test_runner_rack
    puts "\n  --- calling rack" if $VERBOSE
    uri = URI("http://#{$host}:#{$port}/rack/hello")
    req = Net::HTTP::Post.new(uri)
    req['Accept-Encoding'] = '*'
    req['Accept'] = 'application/json'
    req['User-Agent'] = 'Ruby'
    req['Connection'] = 'Close'
    req.body = 'hello'
    resp = Net::HTTP.start(uri.hostname, uri.port) { |h|
      h.request(req)
    }
    puts "\n\n**** resp: #{resp.class} - #{resp.body}\n\n"
  end

  def check_query(client, query, expect)
    puts "  --- query #{query}" if $VERBOSE
    result = client.find(query)
    check_result_code(result)
    assert_equal(expect, result[:results].sort, 'result mistmatch')
  end

  def check_result_code(result)
    assert_equal(0, result[:code], 'result.code should be 0 meaning no error')
  end

  def clear_records(client)
    puts "\n  --- deleting existing records" if $VERBOSE
    result = client.delete('Article')
    check_result_code(result)
  end

  # Returns the reference of the created record.
  def create_records(client)
    puts "  --- create records" if $VERBOSE
    record = {
      kind: 'Article',
      title: 'Sample',
      text: 'Just some random text.'
    }
    result = client.create(record)
    # Make sure the message has the correct fields and values.
    check_result_code(result)
    ref = result[:ref]
    refute_equal(nil, ref, 'create reply record reference can not be nil')
    refute_equal(0, ref, 'create reply record reference can not be 0')

    # create a couple more records
    client.create({
                    kind: 'Article',
                    title: 'Second',
                    text: 'More random text.'})
    client.create({
                    kind: 'Article',
                    title: 'Third',
                    text: 'Even more random text.'})
    ref
  end

  def get_record(client, ref)
    puts "  --- get record" if $VERBOSE
    result = client.read('Article', ref)
    # Make sure the message has the correct fields and values.
    check_result_code(result)
    results = result[:results]
    assert_equal(1, results.length, 'read reply.results should contain exactly one member')
    record = results[0]
    assert_equal(ref, record[:id], 'read reply.results[0].id should match the record reference')
    obj = record[:data]
    assert_equal('Article', obj[:kind], 'read reply obj.kind incorrect')
    assert_equal('Sample', obj[:title], 'read reply obj.title incorrect')
  end

  def read_record(client, ref)
    puts "  --- read record" if $VERBOSE
    result = client.read('Article', {title: 'Sample'})
    # Make sure the message has the correct fields and values.
    check_result_code(result)
    results = result[:results]
    assert_equal(1, results.length, 'read reply.results should contain exactly one member')
    record = results[0]
    assert_equal(ref, record[:id], 'read reply.results[0].id should match the record reference')
    obj = record[:data]
    assert_equal('Article', obj[:kind], 'read reply obj.kind incorrect')
    assert_equal('Sample', obj[:title], 'read reply obj.title incorrect')
  end

  def list_records(client)
    puts "  --- list records" if $VERBOSE
    result = client.read('Article')
    # Make sure the message has the correct fields and values.
    check_result_code(result)
    results = result[:results]
    assert_equal(3, results.length, 'read reply.results should contain all member')
  end

  # Returns the reference of the updated record. There is no requirement that
  # the reference will not change.
  def update_record(client, ref)
    puts "  --- update record" if $VERBOSE
    record = {
      kind: 'Article',
      title: 'Sample',
      text: 'Updated text.'
    }
    result = client.update('Article', record, ref)
    # Make sure the message has the correct fields and values.
    check_result_code(result)
    updated = result[:updated]
    assert_equal(1, updated.length, 'update reply.updated should contain exactly one member')
    ref = updated[0]
    refute_equal(nil, ref, 'update reply record reference can not be nil')
    refute_equal(0, ref, 'update reply record reference can not be 0')
    # verify
    result = client.read('Article', ref)
    check_result_code(result)
    results = result[:results]
    assert_equal(1, results.length, 'read after update reply.results should contain exactly one member')
    record = results[0]
    assert_equal(ref, record[:id], 'read after update reply.results[0].id should match the record reference')
    obj = record[:data]
    assert_equal('Updated text.', obj[:text], 'read after update reply obj.text incorrect')
    ref
  end

  def delete_record(client, ref)
    puts "  --- delete record" if $VERBOSE
    result = client.delete('Article', ref)
    # Make sure the message has the correct fields and values.
    check_result_code(result)
    deleted = result[:deleted]
    assert_equal(1, deleted.length, 'delete reply.deleted should contain exactly one member')
    ref = deleted[0]
    refute_equal(nil, ref, 'delete reply record reference can not be nil')
    refute_equal(0, ref, 'delete reply record reference can not be 0')
    # verify
    result = client.read('Article', ref)
    check_result_code(result)
    results = result[:results]
    assert_equal(0, results.length, 'read after delete reply.results should contain no members')
  end

  def query_records(client)
    puts "  --- query records" if $VERBOSE
    result = client.read('Article', {title: 'Second'})
    check_result_code(result)
    results = result[:results]
    assert_equal(1, results.length, 'read reply.results should contain matching members')
    assert_equal({kind: 'Article', title: 'Second', text: 'More random text.'}, results[0][:data], 'first result should match the inserted')
  end

  def update_query(client)
    puts "  --- update query" if $VERBOSE
    record = {
      kind: 'Article',
      title: 'Sample',
      text: 'Updated text.'
    }
    result = client.update('Article', record, {title: 'Sample'})
    # Make sure the message has the correct fields and values.
    check_result_code(result)
    updated = result[:updated]
    assert_equal(1, updated.length, 'update reply.updated should contain exactly one member')
    ref = updated[0]
    refute_equal(nil, ref, 'update reply record reference can not be nil')
    refute_equal(0, ref, 'update reply record reference can not be 0')
    # verify
    result = client.read('Article', {title: 'Sample'})
    check_result_code(result)
    results = result[:results]
    assert_equal(1, results.length, 'read after update reply.results should contain exactly one member')
    record = results[0]
    assert_equal(ref, record[:id], 'read after update reply.results[0].id should match the record reference')
    obj = record[:data]
    assert_equal('Updated text.', obj[:text], 'read after update reply obj.text incorrect')
  end

  def delete_query(client)
    puts "  --- delete query" if $VERBOSE
    result = client.delete('Article', {title: 'Second'})
    check_result_code(result)
    deleted = result[:deleted]
    assert_equal(1, deleted.length, 'delete reply.deleted should contain exactly one member')
    ref = deleted[0]
    refute_equal(nil, ref, 'delete reply record reference can not be nil')
    refute_equal(0, ref, 'delete reply record reference can not be 0')
    # verify
    result = client.read('Article', {title: 'Second'})
    check_result_code(result)
    assert_equal(0, result[:results].length, 'read after delete reply.results should contain no members')
  end

end # TestRunner
