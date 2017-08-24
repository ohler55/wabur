#!/usr/bin/env ruby
# encoding: UTF-8

$: << File.dirname(__FILE__)
$: << File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'lib')

require 'minitest'
require 'minitest/autorun'
require 'coveralls'

Coveralls.wear!

require 'impl_test'

require 'ioshell_test'
