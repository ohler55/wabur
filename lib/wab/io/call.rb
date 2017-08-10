
require 'wab'

module WAB

  module IO

    class Call

      attr_accessor :rid
      attr_accessor :result
      attr_accessor :thread

      def initialize(timeout=2.0)
        @rid = nil
        @result = nil
        @thread = Thread.current
        @giveup = Time.now + timeout
      end

    end # Call
  end # IO
end # WAB
