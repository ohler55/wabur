
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
        display = List.new(id, 'wab.List', html_list_table(id, list_paths), html_list_row(list_paths))
        add_display(display, true)
      end

      def add_view(kind, template)
        display = View.new("#{kind}.view", 'wab.View')
        # TBD additional configurations
        add_display(display, true)
      end

      def add_create(kind, template)
        display = Create.new("#{kind}.create", 'wab.Create')
        # TBD additional configurations
        add_display(display, true)
      end

      def add_update(kind, template)
        display = Update.new("#{kind}.update", 'wab.Update')
        # TBD additional configurations
        add_display(display, true)
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
        head = list_paths.map { |path| "<th>#{path.capitalize}</th>"}.join('')
        # Add the view, edit, and delete buttons header.
        head += %{<th colspan="3">Actions</th>}
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
        row = list_paths.map { |path| %{<td class="obj-list" path="#{path}"></td>}}.join('')
        buttons = [
                   { title: 'View', icon: 'icon icon-eye', cn: 'actions' },
                   { title: 'Edit', icon: 'icon icon-pencil', cn: 'actions' },
                   { title: 'Delete', icon: 'icon icon-trash-o', cn: 'actions delete' }
                  ].map { |spec|
          %{<td class="#{spec[:cn]}"><span class="#{spec[:icon]}" title="#{spec[:title]}"></span></td>}
        }
        "<tr>#{row}#{buttons}</tr>"
      end

    end # RestFlow
  end # UI
end # WAB

