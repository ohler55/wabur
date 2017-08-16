#!/usr/bin/env ruby
# encoding: UTF-8

require 'wab'

class MirrorController < ::WAB::Controller
  def initialize(shell, async=false)
    super(shell, async)
  end

  def handle(data)
    data
  end

  def create(path, query, data, rid=nil)
    super
  end

  def read(path, query, rid=nil)
    super
  end

  def update(path, query, data, rid=nil)
    super
  end

  def delete(path, query, rid=nil)
    super
  end

  def on_result(data)
    super
  end

end # MirrorController

