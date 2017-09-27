
module WAB
  module UI

    class Display

      attr_reader :name
      attr_reader :kind
      attr_accessor :display_class
      attr_accessor :transitions
      
      def initialize(kind, name, display_class, transitions)
        @name = name
        @display_class = display_class
        @kind = kind
        @transitions = transitions
      end

      def spec
        {
          name: @name,
          kind: @kind,
          display_class: @display_class,
          transitions: @transitions,
        }
      end

    end # Display
  end # UI
end # WAB

