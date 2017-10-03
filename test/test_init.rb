#!/usr/bin/env ruby

require_relative 'helper'
require 'wab/impl'

class TestImplInit < TestImpl

  def setup
    @config = {
      base: File.join(__dir__, 'tmp'),
      rest: ['Entry', 'Article']
    }
    @dir = @config[:base]
    FileUtils.remove_dir @dir if Dir.exist?(@dir)
  end

  def test_setup
    WAB::Impl::Init.setup(File.expand_path(@dir), @config)

    controller = File.read("#{@dir}/lib/ui_controller.rb")
    assert_match /kind: 'Entry',\n/, controller
    assert_match /kind: 'Article',\n/, controller

    wabur_config = File.read("#{@dir}/config/wabur.conf")
    assert_match /handler.1.type = Entry\nhandler.1.handler = WAB::OpenController/, wabur_config
    assert_match /handler.2.type = Article\nhandler.2.handler = WAB::OpenController/, wabur_config

    opo_rub_config = File.read("#{@dir}/config/opo-rub.conf")
    assert_match /handler.entry.path = \/v1\/Entry\/\*\*\nhandler.entry.class = WAB::OpenController/, opo_rub_config
    assert_match /handler.article.path = \/v1\/Article\/\*\*\nhandler.article.class = WAB::OpenController/, opo_rub_config
  end

end # TestImplInit
