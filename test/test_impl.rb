#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'helper'

require 'wab/impl'

class TestImpl < Minitest::Test

  def setup
    @shell = WAB::Impl::Shell.new(
      WAB::Impl::Configuration.from(
        'source' => File.join(__dir__, 'tmp')
      )
    )
  end

  def make_sample_data()
    @shell.data({
                  boo: true,
                  n: nil,
                  num: 7,
                  float: 7.654,
                  str: 'a string',
                  t: Time.gm(2017, 1, 5, 15, 4, 33.123456789),
                  big: BigDecimal('63.21'),
                  uri: URI('http://opo.technology/sample'),
                  uuid: WAB::UUID.new('b0ca922d-372e-41f4-8fea-47d880188ba3'),
                  a: [],
                  h: {},
                })
  end
end # TestImpl

require 'test_data'
require 'test_expr'
require 'test_model'
