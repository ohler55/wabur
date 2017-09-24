
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

      def add_list(kind, template, list_paths)
        display = List.new("#{kind}.list")
        # TBD additional list configurations
        add_display(display, true)
      end

      def add_view(kind, template)
        display = View.new("#{kind}.view")
        # TBD additional configurations
        add_display(display, true)
      end

      def add_create(kind, template)
        display = Create.new("#{kind}.create")
        # TBD additional configurations
        add_display(display, true)
      end

      def add_update(kind, template)
        display = Update.new("#{kind}.update")
        # TBD additional configurations
        add_display(display, true)
      end

    end # RestFlow
  end # UI
end # WAB

