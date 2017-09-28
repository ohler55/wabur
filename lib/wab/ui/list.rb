
module WAB
  module UI

    # Represents a list display.
    class List < Display

      attr_accessor :list_paths
      
      def initialize(kind, id, template, list_paths, transitions)
        super(kind, id, template, transitions, 'ui.List')
        @list_paths = list_paths
      end

      def spec
        ui_spec = super
        ui_spec[:table] = html_table
        ui_spec[:row] = html_row
        ui_spec
      end

      # Returns an HTML string to be used as the table of a list of
      # objects. The table must have an +id+ attribute value of the +name+
      # argument. Generally the column header should include the list_paths or
      # more friendly alternatives. If a create button is desired then an
      # element with the name joined with '.create_button' should be the +id+ of
      # the element.
      def html_table
        html = %{<div class="table-wrapper"><div>#{@kind} List</div><div class="btn" style="float: right;" id="#{@name}.create_button"><span>Create</span></div><table class="obj-list-table" id="#{@name}.table"><tr>}
        # The column headers.
        @list_paths.map { |path| html << "<th>#{path.capitalize}</th>" }
        # Add the view, edit, and delete buttons header.
        html << %{<th colspan="3">Actions</th>}
        html << %{</tr></table></div>}
      end

      # Returns an HTML string to be used as a row in a table of a list of
      # objects. Each column element should include the list_paths identifier
      # as a +path+ element attribute.
      #
      # Each row can contain the buttons +view_button+, +edit_button+, and
      # +delete_button+. These will be used to set up the transitions.
      def html_row
        html = '<tr>'
        @list_paths.map { |path| html << %{<td class="obj-list" path="#{path}"></td>} }
        buttons = [
                   { title: 'View', icon: 'icon icon-eye', cn: 'actions' },
                   { title: 'Edit', icon: 'icon icon-pencil', cn: 'actions' },
                   { title: 'Delete', icon: 'icon icon-trash-o', cn: 'actions delete' }
                  ].map { |spec|
          html << %{<td class="#{spec[:cn]}"><span class="#{spec[:icon]}" title="#{spec[:title]}"></span></td>}
        }
        html << '</tr>'
      end

    end # List
  end # UI
end # WAB

