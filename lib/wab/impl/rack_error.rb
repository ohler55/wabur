
module WAB
  module Impl

    # The RackError class is a logger that is used in the Rack env in a
    # request. It uses the shell logger to log errors.
    class RackError

      # Create a new instance.
      def initialize(shell)
	@shell = shell
      end

      def puts(message)
	@shell.logger.error(message).to_s
      end

      def write(message)
	@shell.logger.error(message)
      end

      def flush
      end
      
    end # RackError
  end # Impl
end # WAB
