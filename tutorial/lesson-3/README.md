
# WABuR Tutorial Lesson 3

In this lesson the HTML of individual pages is modified and the delete
functionality is eliminated.

 - [Eliminate Delete](#eliminate-delete)
 - [Organization](#organization)
 - [Approach](#approach)
 - [Stubs](#stubs)
 - [Change the View](#change-the-view)
 - [Change the Update](#change-the-update)
 - [Change the List](#change-the-list)
 - [Change the Flow](#change-the-flow)

## Eliminate Delete

In our blog we want to disallow the ability to delete entries. In practice you
may or may not agree with removing the delete capability but it allows us to
explore how to make changes in the HTML and flow. This requires changing the
HTML so that the delete buttons are no longer present. It also means the
transitions for those buttons are not longer needed. In all three forms must
be changed.

## Organization

The reference UI for WABuR is the `WAB::UI` module and JavaScript located in
the `export` directory. The design used it that the single page JavaScript
collects templates for each display from WABuR server and uses those templates
to render REST displays. The templates are provided by the server using the
same facility as any other JSON data managed by the WABuR server. A UI
controller provides the templates.

The display templates are organized by each type and referred to as a flow. A
REST flow includes a create, view (read), update, and a list display. Each of
these is reflected in a Ruby class that has methods that build and provide the
template for each display.

Templates are nothing more than HTML with certain elements labeled with an
`id` that is used by the JavaScript to populate the field with values from
data from the Controller. The Ruby classes provide that HTML once when the
JavaScript requests it. It is not generated everytime using ERB. The data
Controllers, such as the Entry controller, provides only the data, not
display. The display is left up to the JavaScript.

HTML templates are provided to the JavaScript but one more bit of information
is needed is needed. Transitions between displays occur when a button is
pressed. This transition information is included with the templates that are
passed from the UI controller to the JavaScript.

## Approach

To changes the displays and the transitions to remove the delete option the
flow for the entry must be changed along with the view, update, and list
displays. That requires modifying or subclassing the UI classes. Looking at
the `lib/ui_controller.rb` file note that a `WAB::UI::RestFlow` is created for
the Entry. This will be replaced with a custom Flow class.

The Flow class creates instances of individual display classes so the Entry
Flow should create custom classes for each display that remove the delete
functionality. This lesson will follow my personal preference to keep things
working and make small incremental change, testing after each change. This
starts with creating a set of stubs for the classes that will be created.

Not that the reference UI implemenation uses straight HTML and not ERB. This
is explained on the page [Why Not ERB](erb.md).

## Stubs

Four files will be created in the `lib` directory, `entry_flow.rb`,
`entry_view.rb`, `entry_update.rb`, and `entry_list.rb`.

`lib/entry_flow.rb`

```ruby
require 'wab/ui'
require 'entry_list'
require 'entry_view'
require 'entry_update'

class EntryFlow < WAB::UI::RestFlow

  def initialize(shell, template, list_paths)
    super(shell, template, list_paths)
  end
end
```

`lib/entry_view.rb`

```ruby
require 'wab/ui'

class EntryView < WAB::UI::View

  def initialize(template, transitions)
    super('Entry', 'Entry.view', template, transitions, 'ui.View')
  end
end
```

`lib/entry_update.rb`

```ruby
require 'wab/ui'

class EntryUpdate < WAB::UI::Update
      
  def initialize(template, transitions)
    super('Entry', 'Entry.update', template, transitions)
  end
end
```

`lib/entry_list.rb`

```ruby
require 'wab/ui'

class EntryList < WAB::UI::List

  def initialize(template, list_paths, transitions)
    super('Entry', 'Entry.list', template, list_paths, transitions)
  end
end
```

The final step is to switch the `ui_controller.rb` to use the new
classes. Change the `add_flow` line in the `ui_controller.rb` so the file
looks like the following.

```ruby
require 'wab/ui'

class UIController < WAB::UI::MultiFlow

  def initialize(shell)
    super
    
    add_flow(EntryFlow.new(shell,
                           {
                             kind: 'Entry',
                             title: '',
                             content: "\n\n\n\n",
                           }, ['$ref', 'title', 'content']))
  end

end # UIController
```

Run with `wabur` and make sure everything works as before. It should look
exactly the same.

## Change the View

The view subclass need only change the `html` method. Copy the `html` method
from `WAB::UI::View` and remove the line that adds the delete button'

```ruby
require 'wab/ui'

class EntryView < WAB::UI::View

  def initialize(template, transitions)
    super('Entry', 'Entry.view', template, transitions, 'ui.View')
  end

  def html
    html = %{<div class="obj-form-frame readonly"><table class="obj-form">}
    html = append_fields(html, @name, template, true)
    html << '</table>'
    html << %{<div class="btn" id="#{@name}.edit_button"><span>Edit</span></div>}
    html << %{<div class="btn" id="#{@name}.list_button"><span>List</span></div>}
    html << '</div>'
  end
end
```

Now modify the `entry_flow.rb` to use the new view class by overriding the
`add_view` method. Note the transitions are left in the flow class. They could
be moved to the view class but keeping the transitions in the flow class makes
it easier to keep track of the overall flow or transition specification.

```ruby
  def add_view(kind, template)
    add_display(EntryView.new(template,
                              {
                                edit: "#{kind}.update",
                                list: "#{kind}.list",
                              }))
  end
```

Run again and make sure the view display no longer includes the delete button.

## Change the Update

The same steps are taken to change the update display. Copy the `html` method
from the `WAB::UI::Update` class and remove the delete button.

```ruby
require 'wab/ui'

class EntryUpdate < WAB::UI::Update
      
  def initialize(template, transitions)
    super('Entry', 'Entry.update', template, transitions)
  end

  def html
    html = %{<div class="obj-form-frame"><table class="obj-form">}
    html = append_fields(html, @name, template, false)
    html << '</table>'
    html << %{<div class="btn" id="#{@name}.save_button"><span>Save</span></div>}
    html << %{<div class="btn" id="#{@name}.cancel_button"><span>Cancel</span></div>}
    html << %{<div class="btn" id="#{@name}.list_button"><span>List</span></div>}
    html << '</div>'
  end
end
```

Then add an `add_update` method to the flow class. It is just a copy of the
`WAB::UI::RestFlow#add_update` method with the transition modified and the new
`EntryUpdate` class use instead of the `WAB::UI::Update` class.

```ruby
  def add_update(kind, template)
      add_display(EntryUpdate.new(template,
                                  {
                                    save: "#{kind}.view",
                                    cancel: "#{kind}.view",
                                    list: "#{kind}.list",
                                  }))
  end
```

Run again and verify the delete button is not in the update or edit display.

## Change the List

The list display include a delete option for each Entry listed. To remove this
the primary HTML is modified to change the `Actions` label to span two table
columns instead of three. Then the `html_row` is changed to not include the
delete icon.

```ruby
require 'wab/ui'

class EntryList < WAB::UI::List

  def initialize(template, list_paths, transitions)
    super('Entry', 'Entry.list', template, list_paths, transitions)
  end

  def html_table
    html = %{<div class="table-wrapper"><h2 style="float: left; margin-top: 2px">#{@kind} List</h2><div class="btn" style="float: left" id="#{@name}.create_button"><span>Create</span></div><table class="obj-list-table" id="#{@name}.table"><tr>}
    @list_paths.map { |path| html << "<th>#{path.capitalize}</th>" }
    html << %{<th colspan="2">Actions</th>}
    html << %{</tr></table></div>}
  end

  def html_row
    html = '<tr>'
    @list_paths.map { |path| html << %{<td class="obj-list" path="#{path}"></td>} }
    buttons = [
               { title: 'View', icon: 'icon icon-eye', cn: 'actions' },
               { title: 'Edit', icon: 'icon icon-pencil', cn: 'actions' },
              ].map { |spec|
      html << %{<td class="#{spec[:cn]}"><span class="#{spec[:icon]}" title="#{spec[:title]}"></span></td>}
    }
    html << '</tr>'
  end
end
```

Like the view and update, the flow must be modified to use the new class. Add the following.

```ruby
  def add_list(kind, template, list_paths)
    add_display(EntryList.new(template, list_paths,
                              {
                                create: "#{kind}.create",
                                view: "#{kind}.view",
                                edit: "#{kind}.update",
                              }), true)
  end
```

Run again and make sure the list view no longer includes the delete option.

## Change the Flow

The flow file is `entry_flow.rb`. When completed it will look like the following.

```ruby
require 'wab/ui'
require 'entry_list'
require 'entry_view'
require 'entry_update'

class EntryFlow < WAB::UI::RestFlow

  def initialize(shell, template, list_paths)
    super(shell, template, list_paths)
  end

  def add_list(kind, template, list_paths)
    add_display(EntryList.new(template, list_paths,
                              {
                                create: "#{kind}.create",
                                view: "#{kind}.view",
                                edit: "#{kind}.update",
                              }), true)
  end

  def add_view(kind, template)
    add_display(EntryView.new(template,
                              {
                                edit: "#{kind}.update",
                                list: "#{kind}.list",
                              }))
  end

  def add_update(kind, template)
      add_display(EntryUpdate.new(template,
                                  {
                                    save: "#{kind}.view",
                                    cancel: "#{kind}.view",
                                    list: "#{kind}.list",
                                  }))
  end
end
```

Make other changes as desired or change the `site/index.html` file to change
the frame surrounding the single page display.

