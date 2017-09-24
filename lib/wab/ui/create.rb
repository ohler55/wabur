
module WAB
  module UI

    # An object create display where the display is built from multiple fields.
    class Create < View
      
      # TBD pass in fields for the create
      def initialize(name)
        super(name)
      end

      def spec
        # TBD other spec fields  as well as the buttons for creating, might have to change button labels from View
        { name: @name }
      end

    end # Create
  end # UI
end # WAB

