
module WAB
  module UI

    # An object create display where the display is built from multiple fields.
    class Create < View
      
      # TBD pass in fields for the create
      def initialize(kind, name, display_class)
        super(kind, name, display_class)
      end

      def spec
        ui_spec = super
        
        # TBD other spec fields like table options, header, and row template
        ui_spec
      end

    end # Create
  end # UI
end # WAB

