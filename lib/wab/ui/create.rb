
module WAB
  module UI

    # An object create display where the display is built from multiple fields.
    class Create < View
      
      # TBD pass in fields for the create
      def initialize(kind, id, template, transitions)
        super(kind, id, template, transitions, 'ui.Create')
      end

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

