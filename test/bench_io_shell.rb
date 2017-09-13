#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

require 'benchmark'

require 'wab/impl'
require 'wab/io'
require 'mirror_controller'

# Windows does not support fork
Process.exit(-1) if RbConfig::CONFIG['host_os'] =~ /(mingw|mswin)/

to_r, to_w = IO.pipe
from_r, from_w = IO.pipe

if fork.nil? # child
  $stdin = to_r
  to_w.close
  $stdout = from_w
  from_r.close

  shell = WAB::IO::Shell.new(1, 'kind', 0)
  shell.timeout = 0.5
  shell.logger.level = Logger::WARN # change to Logger::INFO for debugging
  shell.register_controller(nil, MirrorController.new(shell))
  shell.start

  Process.exit(0)
else
  to_r.close
  from_w.close

  # Using simple timing to make it easier to report results.
  n = 10000
  reply = nil
  start = Time.now
  n.times { |i|
    to_w.puts(WAB::Impl::Data.new({rid: 'rid-read-id', api: 1, body: {op: 'GET', path: ['sample', '12345']}}, false).json)
    to_w.flush
    Oj.strict_load(from_r, symbol_keys: true) { |msg| reply = msg; break }
    to_w.puts(WAB::Impl::Data.new({rid: "#{i+1}", api: 4, body: {code: 0, results:[{kind: 'sample', id: 12345, num: 7}]}}, false).json)
    to_w.flush
    Oj.strict_load(from_r, symbol_keys: true) { |msg| reply = msg; break }
  }
  dt = Time.now - start
  puts "#{n} simulated GETs in #{dt} seconds. #{(dt * 1000000.0 /n).to_i} usecs/GET or #{(n / dt).to_i} GETs/sec"
end
