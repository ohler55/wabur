
module WAB
  module UI

    # A Flow controller that builds up a set of displays and provides those display descriptions
    # when a read is called. The REST UI is built based on the template and
    # list_paths provided in the initializer.
    #
    # The display can be modified or subclassing by changing the View, Create,
    # and Update classes.
    class RestFlow < Flow

      # Creae a new instance based on the record template and path for the
      # list display.
      #
      # shell:: shell containing the instancec
      # template:: and example object with default values
      # list_paths:: paths to values for the list display
      def initialize(shell, template, list_paths)
        super(shell)
        kind = template[:kind]
        raise WAB::ParseError.new('kind field missing from object template') if kind.nil?
        add_list(kind, template, list_paths)
        add_view(kind, template)
        add_create(kind, template)
        add_update(kind, template)
      end

      # Add a listdisplay to the spec delivered to the UI.
      #
      # kind:: the type of record to create the list for
      # template:: and example object with default values
      # list_paths:: paths to values for the list display
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

      # Adds an object view specification.
      #
      # kind:: the type of record to create the list for
      # template:: and example object with default values
      def add_view(kind, template)
        id = "#{kind}.view"
        transitions = {
          edit: "#{kind}.update",
          list: "#{kind}.list",
          delete: "#{kind}.list",
        }
        add_display(View.new(kind, id, template, transitions))
      end

      # Adds an object creation specification.
      #
      # kind:: the type of record to create the list for
      # template:: and example object with default values
      def add_create(kind, template)
        id = "#{kind}.create"
        transitions = {
          save: "#{kind}.view",
          cancel: "#{kind}.list",
        }
        add_display(Create.new(kind, id, template, transitions))
      end

      # Adds an object update specification.
      #
      # kind:: the type of record to create the list for
      # template:: and example object with default values
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

