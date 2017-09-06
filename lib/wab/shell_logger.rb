require 'forwardable'
require 'logger'

module WAB
  # mixin module meant to be 'included' into `WAB::Shell`, `WAB::IO::Shell`
  # and `WAB::Impl::Shell`
  module ShellLogger
    attr_accessor :logger

    extend Forwardable
    def_delegators :@logger, :info?, :warn?, :error?, :info, :warn, :error
  end
end
