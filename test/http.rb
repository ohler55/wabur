#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

require 'wab'
require 'wab/impl'
require 'wab/impl/server'

::WAB::Impl::Server.new(nil, 6363, 'pages', 'v1/')
