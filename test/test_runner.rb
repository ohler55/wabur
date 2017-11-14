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

  # The Runner or rather it's storage is stateful so all steps in the test
  # must be made in order to keep the test self contained. Each step is a
  # separate function though.
  def test_runner_basics
    http = Net::HTTP.new($host, $port)
    client = WAB::Client.new($host, $port)

    # Delete all records to start with a clean database
    puts "\n  --- deleting existing records" if $VERBOSE
    clear_records(client)
    puts "  --- create record" if $VERBOSE
    ref = create_record(client)
    puts "  --- get record" if $VERBOSE
    get_record(client, ref)
    puts "  --- read record" if $VERBOSE
    read_record(client, ref)
    puts "  --- list records" if $VERBOSE
    list_records(client, ref)

    puts "  --- update record" if $VERBOSE
    ref = update_record(client, ref)
    puts "  --- read updated record" if $VERBOSE
    read_after_update(client, ref)

    puts "  --- delete record" if $VERBOSE
    delete_record(client, ref)
    puts "  --- read deleted record" if $VERBOSE
    read_after_delete(client, ref)
  end

  def clear_records(client)
    result = client.delete('Article')
    assert_equal(0, result[:code], 'delete result code was not zero')
  end

  # Returns the reference of the created record.
  def create_record(client)
    record = {
      kind: 'Article',
      title: 'Sample',
      text: 'Just some random text.'
    }
    result = client.create(record)
    # Make sure the message has the correct fields and values.
    assert_equal(0, result[:code], 'create reply.code should be 0 meaning no error')
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
    result = client.read('Article', ref)
    # Make sure the message has the correct fields and values.
    assert_equal(0, result[:code], 'read reply.code should be 0 meaning no error')
    results = result[:results]
    assert_equal(1, results.length, 'read reply.results should contain exactly one member')
    record = results[0]
    assert_equal(ref, record[:id], 'read reply.results[0].id should match the record reference')
    obj = record[:data]
    assert_equal('Article', obj[:kind], 'read reply obj.kind incorrect')
    assert_equal('Sample', obj[:title], 'read reply obj.title incorrect')
  end

  def read_record(client, ref)
    result = client.read('Article', {title: 'Sample'})
    # Make sure the message has the correct fields and values.
    assert_equal(0, result[:code], 'read reply.code should be 0 meaning no error')
    results = result[:results]
    assert_equal(1, results.length, 'read reply.results should contain exactly one member')
    record = results[0]
    assert_equal(ref, record[:id], 'read reply.results[0].id should match the record reference')
    obj = record[:data]
    assert_equal('Article', obj[:kind], 'read reply obj.kind incorrect')
    assert_equal('Sample', obj[:title], 'read reply obj.title incorrect')
  end

  def list_records(client, ref)
    result = client.read('Article')
    # Make sure the message has the correct fields and values.
    assert_equal(0, result[:code], 'read reply.code should be 0 meaning no error')
    results = result[:results]
    assert_equal(3, results.length, 'read reply.results should contain all member')
    # TBD verify all have a kind of Article and also have a title and content field
  end

  # Returns the reference of the updated record. There is no requirement that
  # the reference will not change.
  def update_record(client, ref)
    record = {
      kind: 'Article',
      title: 'Sample',
      text: 'Updated text.'
    }
    result = client.update('Article', record, ref)
    # Make sure the message has the correct fields and values.
    assert_equal(0, result[:code], 'update reply.code should be 0 meaning no error')
    updated = result[:updated]
    assert_equal(1, updated.length, 'update reply.updated should contain exactly one member')
    ref = updated[0]
    refute_equal(nil, ref, 'update reply record reference can not be nil')
    refute_equal(0, ref, 'update reply record reference can not be 0')

    # TBD update different record with query

    ref
  end

  def read_after_update(client, ref)
    result = client.read('Article', ref)
    assert_equal(0, result[:code], 'read after update reply.code should be 0 meaning no error')
    results = result[:results]
    assert_equal(1, results.length, 'read after update reply.results should contain exactly one member')
    record = results[0]
    assert_equal(ref, record[:id], 'read after update reply.results[0].id should match the record reference')
    obj = record[:data]
    assert_equal('Updated text.', obj[:text], 'read after update reply obj.text incorrect')
  end

  def delete_record(client, ref)
    result = client.delete('Article', ref)
    # Make sure the message has the correct fields and values.
    assert_equal(0, result[:code], 'delete reply.code should be 0 meaning no error')
    deleted = result[:deleted]
    assert_equal(1, deleted.length, 'delete reply.deleted should contain exactly one member')
    ref = deleted[0]
    refute_equal(nil, ref, 'delete reply record reference can not be nil')
    refute_equal(0, ref, 'delete reply record reference can not be 0')
  end

  def read_after_delete(client, ref)
    result = client.read('Article', ref)
    assert_equal(0, result[:code], 'read after delete reply.code should be 0 meaning no error')
    results = result[:results]
    assert_equal(0, results.length, 'read after delete reply.results should contain no members')
  end

  # TBD test failure modes as well
  # TBD test multiple matches on update and delete
  # TBD test no matches on update and delete
  # TBD test queries

end # TestRunner
