
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
        kind = template[:kind]
        raise WAB::ParseError.new('kind field missing from object template') if kind.nil?
        add_list(kind, template, list_paths)
        add_view(kind, template)
        add_create(kind, template)
        add_update(kind, template)
      end

      def add_list(kind, template, list_paths)
        id = "#{kind}.list"
        transitions = {
          create: "#{kind}.create",
          view: "#{kind}.view",
          edit: "#{kind}.update",
          delete: id,
        }
        add_display(List.new(kind, id, template, list_paths, transitions), true)
      end

      def add_view(kind, template)
        id = "#{kind}.view"
        transitions = {
          edit: "#{kind}.update",
          list: "#{kind}.list",
          delete: "#{kind}.list",
        }
        add_display(View.new(kind, id, template, transitions))
      end

      def add_create(kind, template)
        id = "#{kind}.create"
        transitions = {
          save: "#{kind}.view",
          cancel: "#{kind}.list",
        }
        add_display(Create.new(kind, id, template, transitions))
      end

      def add_update(kind, template)
        id = "#{kind}.update"
        transitions = {
          save: "#{kind}.view",
          cancel: "#{kind}.view",
          list: "#{kind}.list",
          delete: "#{kind}.list",
        }
        add_display(Update.new(kind, id, template, transitions))
      end

    end # RestFlow
  end # UI
end # WAB

