
module WAB
  module UI

    class List < Display
      
      # TBD pass in fields for the list
      def initialize(name)
        super(name)
      end

      def spec
        # TBD other spec fields like table options, header, and row template
        { name: @name }
      end

    end # List
  end # UI
end # WAB

