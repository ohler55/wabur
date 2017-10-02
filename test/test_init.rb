#!/usr/bin/env ruby

require_relative 'helper'
require 'wab/impl'

class TestImplInit < TestImpl

  def setup
    @config = {
      base: File.join(__dir__, 'tmp'),
      rest: ['Entry', 'Article']
    }
    FileUtils.remove_dir @config[:base]
  end

  def test_setup
    dir = @config[:base]
    WAB::Impl::Init.setup(File.expand_path(dir), @config)

    controller = File.read("#{dir}/lib/ui_controller.rb")
    assert_match %r!kind: 'Entry',\n!, controller
    assert_match %r!kind: 'Article',\n!, controller

    wabur_config = File.read("#{dir}/config/wabur.conf")
    assert_match %r!handler.1.type = Entry\nhandler.1.handler = WAB::OpenController!, wabur_config
    assert_match %r!handler.2.type = Article\nhandler.2.handler = WAB::OpenController!, wabur_config
  end

end # TestImplInit
