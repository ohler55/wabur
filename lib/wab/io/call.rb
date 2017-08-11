
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
        @rid = nil
        @qrid = qrid
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
