
module WAB
  module UI

    # An object update display where the display is built from multiple fields.
    class Update < View
      
      # TBD pass in fields for the update
      def initialize(name)
        super(name)
      end

      def spec
        # TBD other spec fields  as well as the buttons for creating, might have to change button labels from View
        { name: @name }
      end

    end # Update
  end # UI
end # WAB

