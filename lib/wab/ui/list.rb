
module WAB
  module UI

    class List < Display

      attr_accessor :table
      attr_accessor :row
      
      def initialize(name, display_class, table, row)
        super(name, display_class)
        @table = table
        @row = row
      end
      
      def spec
        ui_spec = super
        ui_spec[:table] = @table
        ui_spec[:row] = @row
        ui_spec
      end

    end # List
  end # UI
end # WAB

