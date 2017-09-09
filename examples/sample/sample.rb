#!/usr/bin/env ruby
# encoding: UTF-8

require 'wab'
require 'wab/impl'

class SampleController < ::WAB::Controller

  def initialize(shell)
    super(shell)
  end

  def handle(data)
    # TBD call TQL
    super
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

end # SampleController
