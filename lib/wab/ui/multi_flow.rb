
module WAB
  module UI

    # A Flow controller that merges multiple flows into one single flow.
    class MultiFlow < Flow

      # Create a new instance that can be used to merge multiple flows into
      # one single flow.
      #
      # shell:: shell containing the instancec
      def initialize(shell)
        super(shell)
      end

      def add_flow(flow)
        flow.displays.each_pair { |name,display| @displays[name] = display }
        @entry = flow.entry if @entry.nil?
      end
      
    end # MultiFlow
  end # UI
end # WAB
