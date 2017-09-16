# encoding: UTF-8

require 'wab'

# This controller exposes all possible methods expected in a WAB::Controller
# subclass, as public methods.
#
# Since those methods are private in the superclass, they need to be redefined
# as public methods to enable the concerned functionality.
#
# For example, if a controller is intented to provide only read-access, then
# just the +read+ method would need to be exposed as a public method. The
# remaining methods may remain private.
class EntryController < WAB::Controller

  def initialize(shell)
    super(shell)
  end

  # The +handle+ method is used to catch requests that are not one of the below
  # methods. Since no behavior other than REST calls are needed for this sample,
  # the +handle+ method raises an exception.
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

end # EntryController
