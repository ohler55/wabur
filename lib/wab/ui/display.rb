
module WAB
  module UI

    class Display

      attr_reader :name
      attr_reader :kind
      attr_accessor :display_class
      
      def initialize(kind, name, display_class)
        @name = name
        @display_class = display_class
        @kind = kind
      end

      def spec
        {
          name: @name,
          kind: @kind,
          display_class: @display_class
        }
      end

    end # Display
  end # UI
end # WAB

