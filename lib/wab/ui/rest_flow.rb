
module WAB
  module UI

    # A Flow controller that builds up a set of displays and provides those
    # when a read is called. The REST UI is built based on the template and
    # list_paths provided in the initializer.
    #
    # Methods such as the +html_list_table+ allow the UI specification to be
    # modified with HTML templates.
    class RestFlow < Flow

      def initialize(shell, template, list_paths)
        super(shell)
        # TBD use the template to create the list, create, view, and update
        # displays. Hook up the transitions as well. preface transition and
        # names with the kind from the template.
        kind = template[:kind]
        raise WAB::ParseError.new('kind field missing from object template') if kind.nil?
        add_list(kind, template, list_paths)
        add_view(kind, template)
        add_create(kind, template)
        add_update(kind, template)
        # TBD set up the transitions
      end

      def add_list(kind, template, list_paths)
        id = "#{kind}.list"
        transitions = {
          create: "#{kind}.create",
          view: "#{kind}.view",
          edit: "#{kind}.edit",
          delete: id,
        }
        display = List.new(kind, id, 'ui.List', html_list_table(id, list_paths), html_list_row(list_paths), transitions)
        add_display(display, true)
      end

      def add_view(kind, template)
        id = "#{kind}.view"
        transitions = {
          "#{id}.edit_button": "#{kind}.edit",
          "#{id}.list_button": "#{kind}.list",
          "#{id}.delete_button": "#{kind}.list",
        }
        display = View.new(kind, id, 'ui.View', transitions)
        # TBD additional configurations
        add_display(display)
      end

      def add_create(kind, template)
        id = "#{kind}.create"
        transitions = {
          "#{id}.save_button": "#{kind}.view",
          "#{id}.cancel_button": "#{kind}.list",
        }
        display = Create.new(kind, id, 'ui.Create', transitions)
        # TBD additional configurations
        add_display(display)
      end

      def add_update(kind, template)
        id = "#{kind}.update"
        transitions = {
          "#{id}.save_button": "#{kind}.view",
          "#{id}.cancel_button": "#{kind}.view",
          "#{id}.list_button": "#{kind}.list",
          "#{id}.delete_button": "#{kind}.list",
        }
        display = Update.new(kind, "#{kind}.update", 'ui.Update', transitions)
        # TBD additional configurations
        add_display(display)
      end

      # Returns an HTML string to be used as the table of a list of
      # objects. The table must have an +id+ attribute value of the +id+
      # argument. Generally the column header should include the list_paths or
      # more friendly alternatives. If a create button is desired then an
      # element with the id joined with '.create_button' should be the +id+ of
      # the element.
      #
      # id:: identifier of the table
      # list_paths:: array of field paths into an object that will be displayed
      def html_list_table(id, list_paths)
        # The column headers.
        head = list_paths.map { |path| "<th>#{path.capitalize}</th>"}.join
        # Add the view, edit, and delete buttons header.
        head << %{<th colspan="3">Actions</th>}
        %{<div class="table-wrapper"><div class="btn" id="#{id}.create_button"><span>Create</span></div><table class="obj-list-table" id="#{id}.table"><tr>#{head}</tr></table></div>}
      end

      # Returns an HTML string to be used as a row in a table of a list of
      # objects. Each column element should include the list_paths identifier
      # as a +path+ element attribute.
      #
      # Each row can contain the buttons +view_button+, +edit_button+, and
      # +delete_button+. These will be used to set up the transitions.
      #
      # list_paths:: array of field paths into an object that will be displayed
      def html_list_row(list_paths)
        row = list_paths.map { |path| %{<td class="obj-list" path="#{path}"></td>}}.join
        buttons = [
                   { title: 'View', icon: 'icon icon-eye', cn: 'actions' },
                   { title: 'Edit', icon: 'icon icon-pencil', cn: 'actions' },
                   { title: 'Delete', icon: 'icon icon-trash-o', cn: 'actions delete' }
                  ].map { |spec|
          %{<td class="#{spec[:cn]}"><span class="#{spec[:icon]}" title="#{spec[:title]}"></span></td>}
        }.join
        "<tr>#{row}#{buttons}</tr>"
      end

    end # RestFlow
  end # UI
end # WAB

