
module WAB
  module UI

    class Display

      attr_reader :name
      
      def initialize(name)
        @name = name
      end

      def spec
        { name: @name }
      end

    end # Display
  end # UI
end # WAB

