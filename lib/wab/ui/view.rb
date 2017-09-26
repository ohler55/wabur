
module WAB
  module UI

    # An object view display where the display is built from multiple fields.
    class View < Display

      attr_accessor :fields
      
      # TBD pass in fields for the view
      def initialize(kind, name, display_class)
        super(kind, name, display_class)
        @fields = []
      end

      def add_field(field)
        @fields << field
      end

      def spec
        ui_spec = super
        
        # TBD other spec fields like table options, header, and row template
        ui_spec
      end

    end # Voew
  end # UI
end # WAB
