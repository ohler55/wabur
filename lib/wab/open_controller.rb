
module WAB

  # A Controller that makes all CRUD methods public. The handle method raises
  # as it has to be handled specially.
  class OpenController < Controller

    def initialize(shell)
      super(shell)
    end

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
