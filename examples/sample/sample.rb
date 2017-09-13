#!/usr/bin/env ruby
# encoding: UTF-8

require 'wab'
require 'wab/impl'

# This sample controller uses all the default method on the WAB::Controller by
# making those method public. They are private by default so an explicit
# declaration as public is needed to turn on that functionality. For example,
# if a controller is intented to only provide read access only the read method
# would be made public and the others left private.
class SampleController < WAB::Controller

  def initialize(shell)
    super(shell)
  end

  # The handle method is used to catch requests that were not one of the other
  # methods. Since no behavior is needed other than REST behavior for this
  # sample the handle method raises an exception.
  def handle(data)
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

  def on_result(data)
    super
  end

end # SampleController
