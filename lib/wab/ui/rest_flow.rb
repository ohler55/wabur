
module WAB
  module UI

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
      end

      # TBD raw html can be sent
      def add_listx(kind, template, list_paths)
        id = "#{kind}.list"
        head = list_paths.map { |path| "      <th>#{path.capitalize}</th>" }.join("\n")
        head += %{\n      <th colspan="3">Actions</th>\n}
        table = %{<div class="table-wrapper">
  <div class="btn" id="#{id}.create_button">
    <span>Create</span>
  </div>
  <table class="obj-list-table" id="#{id}.table">
    <tr>
      #{head}
    </tr>
  </table>
</div>
}
        row = '<tr><tr>' # TBD
        display = List.new(id, 'wab.List', table, row)
        add_display(display, true)
      end

      # or json-ized html can be sent
      def add_list(kind, template, list_paths)
        id = "#{kind}.list"
        table = {
          type: 'div',
          'class': 'table-wrapper',
          children: [
                     {
                       type: 'div',
                       'class': 'btn',
                       id: "#{id}.create_button",
                       children: [
                                  {
                                    type: 'span',
                                    children: ['Create'],
                                  }
                                 ]
                     },
                    ]
        }
        row_inner = list_paths.map { |path|
          {
            type: 'td',
            children: ["${#{path}}"],
          }
        }
        # TBD de-dup code here
        row_inner << {
          type: 'td',
          'class': 'actions',
          children: [
                     {
                       type: 'span',
                       'class': 'icon icon-eye',
                       title: 'View'
                     }
                    ]
        }
        row_inner << {
          type: 'td',
          'class': 'actions',
          children: [
                     {
                       type: 'span',
                       'class': 'icon icon-pencil',
                       title: 'Edit'
                     }
                    ]
        }
        row_inner << {
          type: 'td',
          'class': 'actions delete',
          children: [
                     {
                       type: 'span',
                       'class': 'icon icon-trash-o',
                       title: 'Delete'
                     }
                    ]
        }
        row = {
          type: 'tr',
          children: row_inner
        }
                            
        display = List.new(id, 'wab.List', table, row)
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

    end # RestFlow
  end # UI
end # WAB

