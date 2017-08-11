
require 'wab'

module WAB

  module IO

    class Call

      attr_accessor :rid
      attr_accessor :result
      attr_accessor :thread
      attr_accessor :handler # controller

      def initialize(handler, timeout=2.0)
        @rid = nil
        @result = nil
        @giveup = Time.now + timeout
        @handler = handler
        if handler.nil?
          @thread = Thread.current
        else
          @thread = nil
        end
      end

    end # Call
  end # IO
end # WAB
