#!/usr/bin/env ruby
# encoding: UTF-8

$: << __dir__
$: << File.join(File.dirname(__dir__), 'lib')

require 'minitest'
require 'minitest/autorun'

require 'wab/impl'

$shell = ::WAB::Impl::Shell.new(nil, nil)

require 'data_test'
