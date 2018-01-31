module WAB

  # A Racker or a duck-typed alternative should be created and
  # registered with a Shell for paths that expected to follow the Ruby rack API.
  class Racker # :doc: all
    attr_accessor :shell

    # Create a instance.
    def initialize(shell)
      @shell = shell
    end

    # Rack handler for processing rack requests. Implemenation should follow
    # the rack API described at https://rack.github.io.
    #
    # env:: data to be processed
    #
    # return:: a rack compliant response.
    def call(env)
      [200, {}, ['A WABuR Rack Application']]
    end

  end
end
