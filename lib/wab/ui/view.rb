
module WAB
  module UI

    # An object view display where the display is built from multiple fields.
    class View < Display

      attr_accessor :fields
      
      # TBD pass in fields for the view
      def initialize(name)
        super(name)
        @fields = []
      end

      def add_field(field)
        @fields << field
      end

      def spec
        # TBD other spec fields 
        { name: @name }
      end

    end # Voew
  end # UI
end # WAB
