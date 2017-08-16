
require 'wab'

module WAB

  module IO

    class Call

      attr_accessor :rid
      attr_accessor :result
      attr_accessor :thread
      attr_accessor :handler # controller
      attr_accessor :qrid
      attr_accessor :giveup
      
      def initialize(handler, qrid, timeout=2.0)
        @qrid = qrid
        @giveup = Time.now + timeout
        @handler = handler
        @thread = Thread.current if handler.nil?
      end

    end # Call
  end # IO
end # WAB
