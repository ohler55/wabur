#!/usr/bin/env ruby
# encoding: UTF-8

require 'wab'
require 'wab/impl'

class MirrorController < WAB::OpenController
  def initialize(shell)
    super(shell)
  end

  def handle(data)
    data
  end

end # MirrorController
