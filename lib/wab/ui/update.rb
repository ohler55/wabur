
module WAB
  module UI

    # An object update display where the display is built from multiple fields.
    class Update < View
      
      # TBD pass in fields for the update
      def initialize(name, display_class)
        super(name, display_class)
      end

      def spec
        ui_spec = super
        
        # TBD other spec fields like table options, header, and row template
        ui_spec
      end

    end # Update
  end # UI
end # WAB

