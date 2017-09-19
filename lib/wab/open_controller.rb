
module WAB

  # This controller exposes all possible methods expected in a WAB::Controller
  # subclass, as public methods.
  #
  # Since those methods are private in the superclass, they need to be redefined
  # as public methods to enable the concerned functionality.
  #
  # For example, if a controller is intented to provide only read-access, then
  # just the +read+ method would need to be exposed as a public method. The
  # remaining methods may remain private.
  class OpenController < Controller

    def initialize(shell)
      super(shell)
    end

    # Catch requests that are not one of the below CRUD methods.
    #
    # Raises as it has to be handled specially.
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

  end # OpenController
end # WAB
