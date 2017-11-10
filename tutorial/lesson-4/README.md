
# WABuR Tutorial Lesson 4

In this lesson a custom controller is created to add a read-only timestamp to
the blog entries.

 - [Approach](#approach)
 - [Controller](#controller)
 - [Displays](#displays)

## Approach

It would be nice to have an indication of when a blog entry was created. That
should not be left up to the author and it should not be editable. There are a
few things that need to be done to implement this feature. First the
controller should be updated so that on create a timestamp is added. Next the
view and edit displays should show the timestamp as read only.

## Controller

The default controller for the Entry records is the `WAB::OpenController`. In
addition to the default bahavior for the Entry controller the current time
should be added to the data before it is saved in the database. To do that a
subclass of the `WAB::OpenController` controller is made and in the subclass
`create` method the current time is added.

The first step is to create the new controller class. Lets call it
`EntryController` since it is the controller for Entry records. Create a file
called `entry_controller.rb` in the project `lib` directory. The file should
look like this.

```ruby
require 'wab/open_controller'

class EntryController < WAB::OpenController

  def initialize(shell)
    super(shell)
  end

  def create(path, query, data)
    data.set(:when, Time.now)
    super
  end

end
```

Note that the `data` argument to create is a `WAB::Data` type or one that has
the same method as `WAB::Data` objects.

After creating the class, the runner has to be told to use that class instead
of `WAB::OpenController`. Open the `config/wabur.conf` file and find the line
that looks like this.

```
handler.1.handler = WAB::OpenController
```

and change it to

```
handler.1.handler = EntryController
```

The `wabur` runner will not use the `EntryController` class for all Entry records.

A similar change can be made to the `config/opo-rub.conf` file if desired. The
use of that file an alternative runners will be covered in a later lesson.

```
handler.entry.class = WAB::OpenController
```

should be changes to

```
handler.entry.class = EntryController
```

Thats all that is required for the controller. The next step is to modify the
displays.

## Displays

Two displays need to be changed in order to see the new timestamp placed in
the records. The View and Update displays should show the timestamp as a
readonly attribute. The Create display does not need to be changed as the
timestamp has not been added at that point. The list does not change unless we
want the timestamp shown with each record.

The HTML for each of the displays is changed by modifying the associated UI
controller class so that it provides the desired HTML. The
`lib/entry_update.rb` file was created in a previous lesson. It will be
modified by adding an extra line to display the timestamp. The WAB JavaScript
has some options for displaying values in different format. The `alt` tag is
used to relay the display option to the JavaScript code. We want the time
displayed as local time so a `alt` value of `local-time` is used. Modify the
`lib/entry_update.rb` file by adding a line so that it looks like the
following.

```ruby
require 'wab/ui'

class EntryUpdate < WAB::UI::Update
      
  def initialize(template, transitions)
    super('Entry', 'Entry.update', template, transitions)
  end

  def html
    html = %{<div class="obj-form-frame"><table class="obj-form">}
    html << %{<tr><td class="field-label">When</td><td><input class="form-field" id="Entry.update.when" type="text" value="" alt="local-time" readonly></td></tr>}
    html = append_fields(html, @name, template, false)
    html << '</table>'
    html << %{<div class="btn" id="#{@name}.save_button"><span>Save</span></div>}
    html << %{<div class="btn" id="#{@name}.cancel_button"><span>Cancel</span></div>}
    html << %{<div class="btn" id="#{@name}.list_button"><span>List</span></div>}
    html << '</div>'
  end
end
```

The second line of the `html` method is the new line. It adds a label of
'When' and has an `id` corresponding to the timestamp (`when`) element of the
Entry records.

The View should also be updated in the same way using the same line. A new
`lib/entry_view.rb` file should look like the following after creation.

```ruby
require 'wab/ui'

class EntryView < WAB::UI::View

  def initialize(template, transitions)
    super('Entry', 'Entry.view', template, transitions, 'ui.View')
  end

  def html
    html = %{<div class="obj-form-frame readonly"><table class="obj-form">}
    html << %{<tr><td class="field-label">When</td><td><input class="form-field" id="Entry.view.when" type="text" value="" alt="local-time" readonly></td></tr>}
    html = append_fields(html, @name, template, true)
    html << '</table>'
    html << %{<div class="btn" id="#{@name}.edit_button"><span>Edit</span></div>}
    html << %{<div class="btn" id="#{@name}.list_button"><span>List</span></div>}
    html << '</div>'
  end
end
```

That all the changes needed. Run it and try it out.

