#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

require 'wab/impl'
require 'wab/io'
require 'mirror_controller'

class IoEngineTest < Minitest::Test

  def test_default_controller
    run_fork_test([
                   [{rid: 'rid-mirror', api: 1, body: {kind: 'sample', num: 7}},
                    {rid: 'rid-mirror', api: 2, body: {kind: 'sample', num: 7}}]
                  ])
  end

  def test_create
    run_fork_test([
                   [{rid: 'rid-create', api: 1, body: {op: 'NEW', path: ['sample'], content: {kind: 'sample', num: 7}}},
                    {rid: '1', api: 3, body: { insert:{ kind: 'sample', num: 7}}}],
                   [{rid: '1', api: 4, body: {ref: 123, code: 0}},
                    {rid: 'rid-create', api: 2, body: { ref: 123, code: 0}}]
                  ])
  end

  def test_create_with_where
    run_fork_test([
                   [{rid: 'rid-create-where', api: 1, body: {op: 'NEW', path: ['sample'], query: {id: 12345}, content: {kind: 'sample', id: 12345, num: 7}}},
                    {rid: '1', api: 3, body: {where: ['AND', ['EQ', 'kind', "'sample"],['EQ', 'id', 12345]], insert:{ kind: 'sample', id: 12345, num: 7}}}],
                   [{rid: '1', api: 4, body: {ref: 123, code: 0}},
                    {rid: 'rid-create-where', api: 2, body: { ref: 123, code: 0 }}]
                  ])
  end

  def test_create_error
    run_fork_test([
                   [{rid: 'rid-create-error', api: 1, body: {op: 'NEW', path: ['sample'], content: {kind: 'sample', num: 7}}},
                    {rid: '1', api: 3, body: { insert:{ kind: 'sample', num: 7}}}],
                   [{rid: '1', api: 4, body: {ref: 123, code: -1, error: "something went wrong"}},
                    {rid: 'rid-create-error', api: 2, body: { code: -1, error: "WAB::Error: error on sample create. something went wrong", rid: 'rid-create-error'}}]
                  ])
  end

  def test_read_by_id
    run_fork_test([
                   [{rid: 'rid-read-id', api: 1, body: {op: 'GET', path: ['sample', '12345']}},
                    {rid: '1', api: 3, body: {where: 12345, select: '$'}}],
                   [{rid: '1', api: 4, body: {code: 0, results:[{kind: 'sample', id: 12345, num: 7}]}},
                    {rid: 'rid-read-id', api: 2, body: { code: 0, results:[{ id: 12345, data: { kind: 'sample', id: 12345, num: 7}}], rid: 'rid-read-id'}}]
                  ])
  end

  def test_read_by_attrs
    run_fork_test([
                   [{rid: 'rid-read-attrs', api: 1, body: {op: 'GET', path: ['sample'], query: {id: 12345}}},
                    {rid: '1', api: 3, body: {where: ['AND', ['EQ', 'kind', "'sample"], ['EQ', 'id', 12345]], select: {id: '$ref', data: '$' }}}],
                   [{rid: '1', api: 4, body: {code: 0, results: [{id: 12345, data: {kind: 'sample', id: 12345, num: 7}}]}},
                    {rid: 'rid-read-attrs', api: 2, body: {code: 0, results:[{id: 12345, data: {kind: 'sample', id: 12345, num: 7}}]}}]
                  ])
  end

  def test_read_list
    run_fork_test([
                   [{rid: 'rid-read-list', api: 1, body: {op: 'GET', path: ['sample']}},
                    {rid: '1', api: 3, body: {where: ['EQ', 'kind', "'sample"], select: { id: '$ref', data: '$'}}}],
                   [{rid: '1', api: 4, body: {code: 0, results: [12345]}},
                    {rid: 'rid-read-list', api: 2, body: {code: 0, results:[12345]}}]
                  ])
  end

  def test_read_select
    run_fork_test([
                   [{rid: 'rid-read-select', api: 1, body: {op: 'GET', path: ['sample', 'list'], query: { Age: 'num' }}},
                    {rid: '1', api: 3, body: {where: ['EQ', 'kind', "'sample"], select: { ref: '$ref', Age: "num"}}}],
                   [{rid: '1', api: 4, body: {code: 0, results: [{ref: 12345, Age: 7 }]}},
                    {rid: 'rid-read-select', api: 2, body: {code: 0, results:[{ref: 12345, Age: 7 }]}}]
                  ])
  end

  def test_update_by_id
    run_fork_test([
                   [{rid: 'rid-update-id', api: 1, body: {op: 'MOD', path: ['sample', '12345'], content: {kind: 'sample', id: 12345, num: 7}}},
                    {rid: '1', api: 3, body: {where: 12345, update: { kind: 'sample', id: 12345, num: 7}}}],
                   [{rid: '1', api: 4, body: {code: 0, updated: [12345]}},
                    {rid: 'rid-update-id', api: 2, body: { code: 0, updated: [12345]}}]
                  ])
  end

  def test_update_by_attrs
    run_fork_test([
                   [{rid: 'rid-update-attrs', api: 1, body: {op: 'MOD', path: ['sample'], query: {id: 12345}, content: {kind: 'sample', id: 12345, num: 7}}},
                    {rid: '1', api: 3, body: {where: ['AND', ['EQ', 'kind', "'sample"],['EQ', 'id', 12345]], update: { kind: 'sample', id: 12345, num: 7}}}],
                   [{rid: '1', api: 4, body: {code: 0, updated: [12345]}},
                    {rid: 'rid-update-attrs', api: 2, body: { code: 0, updated: [12345]}}]
                  ])
  end

  def test_delete_by_id
    run_fork_test([
                   [{rid: 'rid-delete-id', api: 1, body: {op: 'DEL', path: ['sample', '12345']}},
                    {rid: '1', api: 3, body: {where: 12345, delete: nil}}],
                   [{rid: '1', api: 4, body: {code: 0, deleted: [12345]}},
                    {rid: 'rid-delete-id', api: 2, body: { code: 0, deleted: [12345]}}]
                  ])
  end

  def test_delete_by_attrs
    run_fork_test([
                   [{rid: 'rid-delete-attrs', api: 1, body: {op: 'DEL', path: ['sample'], query: {id: 12345}}},
                    {rid: '1', api: 3, body: {where: ['AND', ['EQ', 'kind', "'sample"],['EQ', 'id', 12345]], delete: nil}}],
                   [{rid: '1', api: 4, body: {code: 0, deleted: [12345]}},
                    {rid: 'rid-delete-attrs', api: 2, body: { code: 0, deleted: [12345]}}]
                  ])
  end

  ##### Async controller tests.
  
  def test_default_controller_async
    run_fork_test([
                   [{rid: 'rid-mirror', api: 1, body: {kind: 'sample', num: 7}},
                    {rid: 'rid-mirror', api: 2, body: {kind: 'sample', num: 7}}]
                  ], true)
  end

  def test_create_async
    run_fork_test([
                   [{rid: 'rid-create', api: 1, body: {op: 'NEW', path: ['sample'], content: {kind: 'sample', num: 7}}},
                    {rid: '1', api: 3, body: { insert:{ kind: 'sample', num: 7}, rid: 'rid-create'}}],
                   [{rid: '1', api: 4, body: {ref: 123, code: 0, rid: 'rid-create'}},
                    {rid: 'rid-create', api: 2, body: { ref: 123, code: 0, rid: 'rid-create'}}]
                  ], true)
  end

  def test_create_with_where_async
    run_fork_test([
                   [{rid: 'rid-create-where', api: 1, body: {op: 'NEW', path: ['sample'], query: {id: 12345}, content: {kind: 'sample', id: 12345, num: 7}}},
                    {rid: '1', api: 3, body: {where: ['AND', ['EQ', 'kind', "'sample"],['EQ', 'id', 12345]], insert:{ kind: 'sample', id: 12345, num: 7}, rid: 'rid-create-where'}}],
                   [{rid: '1', api: 4, body: {ref: 123, code: 0, rid: 'rid-create-where'}},
                    {rid: 'rid-create-where', api: 2, body: { ref: 123, code: 0, rid: 'rid-create-where' }}]
                  ], true)
  end

  def test_create_error_async
    run_fork_test([
                   [{rid: 'rid-create-error', api: 1, body: {op: 'NEW', path: ['sample'], content: {kind: 'sample', num: 7}}},
                    {rid: '1', api: 3, body: { insert:{ kind: 'sample', num: 7}, rid: 'rid-create-error'}}],
                   [{rid: '1', api: 4, body: { code: -1, error: "something went wrong", rid: 'rid-create-error'}},
                    {rid: 'rid-create-error', api: 2, body: { code: -1, error: "something went wrong", rid: 'rid-create-error'}}]
                  ], true)
  end

  def test_read_by_id_async
    run_fork_test([
                   [{rid: 'rid-read-id', api: 1, body: {op: 'GET', path: ['sample', '12345']}},
                    {rid: '1', api: 3, body: {where: 12345, select: '$'}}],
                   [{rid: '1', api: 4, body: {code: 0, results:[{kind: 'sample', id: 12345, num: 7}], rid: 'rid-read-id'}},
                    {rid: 'rid-read-id', api: 2, body: { code: 0, results:[{ id: 12345, data: { kind: 'sample', id: 12345, num: 7}}], rid: 'rid-read-id'}}]
                  ], true)
  end

  def test_read_by_attrs_async
    run_fork_test([
                   [{rid: 'rid-read-attrs', api: 1, body: {op: 'GET', path: ['sample'], query: {id: 12345}}},
                    {rid: '1', api: 3, body: {where: ['AND', ['EQ', 'kind', "'sample"], ['EQ', 'id', 12345]], select: {id: '$ref', data: '$'}, rid: 'rid-read-attrs'}}],
                   [{rid: '1', api: 4, body: {code: 0, results: [{id: 12345, data: {kind: 'sample', id: 12345, num: 7}}], rid: 'rid-read-attrs'}},
                    {rid: 'rid-read-attrs', api: 2, body: {code: 0, results:[{id: 12345, data: {kind: 'sample', id: 12345, num: 7}}], rid: 'rid-read-attrs'}}]
                  ], true)
  end

  def test_read_list_async
    run_fork_test([
                   [{rid: 'rid-read-list', api: 1, body: {op: 'GET', path: ['sample']}},
                    {rid: '1', api: 3, body: {where: ['EQ', 'kind', "'sample"], select: { id: '$ref', data: '$'}, rid: 'rid-read-list'}}],
                   [{rid: '1', api: 4, body: {code: 0, results: [12345], rid: 'rid-read-list'}},
                    {rid: 'rid-read-list', api: 2, body: {code: 0, results:[12345], rid: 'rid-read-list'}}]
                  ], true)
  end

  def test_update_by_id_async
    run_fork_test([
                   [{rid: 'rid-update-id', api: 1, body: {op: 'MOD', path: ['sample', '12345'], content: {kind: 'sample', id: 12345, num: 7}}},
                    {rid: '1', api: 3, body: {where: 12345, update: { kind: 'sample', id: 12345, num: 7}, rid: 'rid-update-id'}}],
                   [{rid: '1', api: 4, body: {code: 0, updated: [12345], rid: 'rid-update-id'}},
                    {rid: 'rid-update-id', api: 2, body: { code: 0, updated: [12345], rid: 'rid-update-id'}}]
                  ], true)
  end

  def test_update_by_attrs_async
    run_fork_test([
                   [{rid: 'rid-update-attrs', api: 1, body: {op: 'MOD', path: ['sample'], query: {id: 12345}, content: {kind: 'sample', id: 12345, num: 7}}},
                    {rid: '1', api: 3, body: {where: ['AND', ['EQ', 'kind', "'sample"],['EQ', 'id', 12345]], update: { kind: 'sample', id: 12345, num: 7}, rid: 'rid-update-attrs'}}],
                   [{rid: '1', api: 4, body: {code: 0, updated: [12345], rid: 'rid-update-attrs'}},
                    {rid: 'rid-update-attrs', api: 2, body: { code: 0, updated: [12345], rid: 'rid-update-attrs'}}]
                  ], true)
  end

  def test_delete_by_id_async
    run_fork_test([
                   [{rid: 'rid-delete-id', api: 1, body: {op: 'DEL', path: ['sample', '12345']}},
                    {rid: '1', api: 3, body: {where: 12345, delete: nil, rid: 'rid-delete-id'}}],
                   [{rid: '1', api: 4, body: {code: 0, deleted: [12345], rid: 'rid-delete-id'}},
                    {rid: 'rid-delete-id', api: 2, body: { code: 0, deleted: [12345], rid: 'rid-delete-id'}}]
                  ], true)
  end

  def test_delete_by_attrs_async
    run_fork_test([
                   [{rid: 'rid-delete-attrs', api: 1, body: {op: 'DEL', path: ['sample'], query: {id: 12345}}},
                    {rid: '1', api: 3, body: {where: ['AND', ['EQ', 'kind', "'sample"],['EQ', 'id', 12345]], delete: nil, rid: 'rid-delete-attrs'}}],
                   [{rid: '1', api: 4, body: {code: 0, deleted: [12345], rid: 'rid-delete-attrs'}},
                    {rid: 'rid-delete-attrs', api: 2, body: { code: 0, deleted: [12345], rid: 'rid-delete-attrs'}}]
                  ], true)
  end

  def test_timeout
    run_fork_test([
                   [{rid: 'rid-timeout', api: 1, body: {op: 'NEW', path: ['sample'], content: {kind: 'sample', num: 7}}},
                    {rid: '1', api: 3, body: { insert:{ kind: 'sample', num: 7}}}],
                   [nil,
                    {rid: 'rid-timeout', api: 2, body: { code: -1, error: 'WAB::Error: error on sample create. Timed out waiting for 1.', rid: 'rid-timeout'}}]
                  ])
  end

  def test_timeout_async
    run_fork_test([
                   [{rid: 'rid-timeout', api: 1, body: {op: 'NEW', path: ['sample'], content: {kind: 'sample', num: 7}}},
                    {rid: '1', api: 3, body: { insert:{ kind: 'sample', num: 7}, rid: 'rid-timeout'}}],
                   [nil,
                    {rid: 'rid-timeout', api: 2, body: { code: -1, error: 'Timed out waiting for 1.', rid: 'rid-timeout'}}]
                  ], true)
  end

  # Fork and create a shell in the child. For each pair in the script send the
  # first message and wait for the second. Compare second for test success of
  # failure.
  def run_fork_test(script, async=false)
    # Windows does not support fork
    return if RbConfig::CONFIG['host_os'] =~ /(mingw|mswin)/

    to_r, to_w = IO.pipe
    from_r, from_w = IO.pipe

    if fork.nil? # child
      $stdin = to_r
      to_w.close
      $stdout = from_w
      from_r.close

      shell = ::WAB::IO::Shell.new(2, 'kind', 0)
      shell.timeout = 0.5
      shell.verbose = false # change to true to debug
      shell.register_controller(nil, MirrorController.new(shell, async))
      shell.start

      Process.exit(0)
    else
      to_r.close
      from_w.close

      # Shell#data should be called instead but for this test a shell is not
      # desired.
      script.each { |pair|
        unless pair[0].nil?
          to_w.puts(::WAB::Impl::Data.new(pair[0], false).json)
          to_w.flush
        end

        reply = nil
        Oj.strict_load(from_r, symbol_keys: true) { |msg| reply = msg; break }

        # remove backtrace if an error
        bt = nil
        if !reply.nil? && !reply[:body].nil?
          bt = reply[:body].delete(:backtrace)
        end
        begin
          assert_equal(pair[1], reply)
        rescue Exception => e
          puts ''
          puts bt
          raise e
        end
      }
      # On error the pipe may be closed from the child side so the write will
      # fail. Thats okay as the write is only to tell the child to shutdown
      # and it already has.
      begin
        to_w.puts(::WAB::Impl::Data.new({ api: -2 }, false).json)
        to_w.flush
      rescue Exception
      end
    end
  end

end
