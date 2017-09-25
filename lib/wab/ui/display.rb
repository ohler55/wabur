
module WAB
  module UI

    class Display

      attr_reader :name
      attr_accessor :display_class
      
      def initialize(name, display_class)
        @name = name
        @display_class = display_class
      end

      def spec
        {
          name: @name,
          display_class: @display_class
        }
      end

    end # Display
  end # UI
end # WAB

