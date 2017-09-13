#!/usr/bin/env ruby
# encoding: UTF-8

require 'wab'

class MirrorController < WAB::Controller
  def initialize(shell)
    super(shell)
  end

  def handle(data)
    data
  end

  def create(path, query, data)
    super
  end

  def read(path, query)
    super
  end

  def update(path, query, data)
    super
  end

  def delete(path, query)
    super
  end

  def on_result(data)
    super
  end

end # MirrorController

