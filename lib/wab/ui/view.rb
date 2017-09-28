
module WAB
  module UI

    # An object view display.
    class View < Display

      def initialize(kind, id, template, transitions, display_class='ui.View')
        super(kind, id, template, transitions, display_class)
      end

      def spec
        ui_spec = super
        ui_spec[:html] = html
        ui_spec
      end

      def html
        html = %{<div class="obj-form-frame readonly"><table class="obj-form">}
        html = append_fields(html, @name, template, true)
        html << '</table>'
        html << %{<div class="btn" id="#{@name}.edit_button"><span>Edit</span></div>}
        html << %{<div class="btn" id="#{@name}.list_button"><span>List</span></div>}
        html << %{<div class="btn delete-btn" style="float:right;" id="#{@name}.delete_button"><span>Delete</span></div>}
        html << '</div>'
      end

      def append_fields(html, path, template, readonly)
        readonly = readonly ? ' readonly' : ''
        template.each_pair { |id,value|
          next if :kind == id
          input = nil
          input_id = "#{path}.#{id}"

          if value.is_a?(String)
            count = value.count("\n")
            if 0 < count # a text area
              input = %{<textarea class="form-field" id="#{input_id}" rows="#{count}" #{readonly}>#{value.strip}</textarea>}
            else
              input = %{<input class="form-field" id="#{input_id}" type="text" value="#{value}" #{readonly}>}
            end
          elsif value.is_a?(TrueClass)
            input = %{<input class="form-field" id="#{input_id}" type="checkbox" checked>}
          elsif value.is_a?(FalseClass)
            input = %{<input class="form-field" id="#{input_id}" type="checkbox">}
          elsif value.is_a?(Integer) || WAB::Utils.pre_24_fixnum?(value) || value.is_a?(Number)
            input = %{<input class="form-field" id="#{input_id}" type="number" value="#{value}" #{readonly}>}
          elsif value.is_a?(Hash)
            append_fields(html, input_id, value)
          else
            input = %{<input class="form-field" id="#{input_id}" type="text" value="#{value}" #{readonly}>}
          end
          html << %{<tr><td class="field-label">#{id.capitalize}</td><td>#{input}</td></tr>}
        }
        html
      end

    end # View
  end # UI
end # WAB
