#!/usr/bin/env ruby
# encoding: UTF-8

require 'wab'
require 'wab/impl'

class SampleController < WAB::OpenController

=begin # uncomment the various methods as necessary

  def initialize(shell)
    super(shell)
  end

  def handle(_data)
    raise NotImplementedError.new
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

=end

end # SampleController
