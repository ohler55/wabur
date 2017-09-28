
module WAB
  module UI

    # Base class for other displays.
    class Display

      attr_reader :name
      attr_reader :kind
      attr_accessor :template
      attr_accessor :display_class
      attr_accessor :transitions

      def initialize(kind, name, template, transitions, display_class)
        @kind = kind
        @name = name
        @template = template
        @display_class = display_class
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

