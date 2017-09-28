
module WAB
  module UI

    # An object create display.
    class Create < View
      
      # Create an instance that will generate the HTML for a display.
      def initialize(kind, id, template, transitions)
        super(kind, id, template, transitions, 'ui.Create')
      end

      # Returns the HTML for a display.
      def html
        html = %{<div class="obj-form-frame"><table class="obj-form">}
        html = append_fields(html, @name, template, false)
        html << '</table>'
        html << %{<div class="btn" id="#{@name}.save_button"><span>Save</span></div>}
        html << %{<div class="btn" style="float:right;" id="#{@name}.cancel_button"><span>Cancel</span></div>}
        html << '</div>'
      end

    end # Create
  end # UI
end # WAB

