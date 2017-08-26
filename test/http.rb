#!/usr/bin/env ruby
# encoding: UTF-8

$: << __dir__
$: << File.join(File.dirname(File.expand_path(__dir__)), 'lib')

require 'wab'
require 'wab/impl'
require 'wab/impl/server'

::WAB::Impl::Server.new(nil, 6363, 'pages', 'v1/')

