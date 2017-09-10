
module WAB

  module IO

    class Call

      attr_accessor :result
      attr_accessor :thread
      attr_accessor :rid
      attr_accessor :giveup

      def initialize(timeout=2.0)
        @rid = rid
        @giveup = Time.now + timeout
        @thread = Thread.current
      end

    end # Call
  end # IO
end # WAB
