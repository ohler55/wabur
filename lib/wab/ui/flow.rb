
module WAB
  module UI

    # A controller that provides a description of the UI for the WAB UI
    # reference implementation.
    class Flow < WAB::Controller

      attr_accessor :entry
      attr_reader :displays
      
      def initialize(shell)
        super
        @displays = {}
      end

      # Adds a display to the flow.
      def add_display(display, entry=false)
        name = display.name
        raise DuplicateError.new(name) if @displays.has_key?(name)
        @displays[name] = display
        @entry = name if entry
      end

      def get_display(name)
        @displays[name]
      end

      # Returns a description of the UI to be used. If a display name is
      # includd in the path thenn just that display description is returned.
      #
      # path:: array of tokens in the path.
      def read(path, _query)
        results = []
        if @shell.path_pos + 2 == path.length
          # Return the description of the named display.
          name = path[@shell.path_pos + 1]
          display = get_display(name)
          display[:entry] = true if !display.nil? && display.name == @entry
          results << {id: name, data: display.spec} unless display.nil?
        else
          @displays.each_value { |display|
            spec = display.spec
            spec[:entry] = true if display.name == @entry
            results << spec
          }
        end
        @shell.data({code: 0, results: results})
      end
      
    end # Flow
  end # UI
end # WAB

