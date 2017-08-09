#!/usr/bin/env ruby
# encoding: UTF-8

require 'minitest'
require 'minitest/autorun'

require_relative '../lib/wab'
require_relative 'data_test'

$shell = ::WAB::Impl::Shell.new(nil, nil)

