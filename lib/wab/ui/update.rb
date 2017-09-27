
module WAB
  module UI

    # An object update display where the display is built from multiple fields.
    class Update < View
      
      # TBD pass in fields for the update
      def initialize(kind, id, template, transitions)
        super(kind, id, template, transitions, 'ui.Update')
      end

      def html
        html = %{<div class="obj-form-frame"><table class="obj-form">}
        html = append_fields(html, @name, template, false)
        html << '</table>'
        html << %{<div class="btn" id="#{@name}.save_button"><span>Save</span></div>}
        html << %{<div class="btn" id="#{@name}.cancel_button"><span>Cancel</span></div>}
        html << %{<div class="btn" id="#{@name}.list_button"><span>List</span></div>}
        html << %{<div class="btn" style="float:right;" id="#{@name}.delete_button"><span>Delete</span></div>}
        html << '</div>'
      end

    end # Update
  end # UI
end # WAB

