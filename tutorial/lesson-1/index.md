
# WABuR Tutorial Lesson 1

This first lesson of the WABuR Tutorial covers.

 - [Application Design](#application-design)
 - [WABuR Components and Terminology](#wabur-components-and-terminology)
 - [Development Environment](#development-environment)
 - [File and Directory Organization](#file-and-directory-organization)
 - [Implementation](#implementation)
 - [Running](#running)
 - [Testing](#testing)

## Application Design

The first step in building any application it deciding what to build. WAB is
object based to the design and planning will follow an object based
design. With that in mind, building a blog will require blog entries so an
Entry will be the primary object type in the application.

An Entry will initially have two attributes, a title and content. Later more
attributes will be added but to start with those two attributes will be
sufficient. The canonical data representation is JSON so in this tutorial JSON
will be used to describe objects and data.

For the blog a list of Entries is desired. In addition the standard CRUD
operations of Create, Read, Update, and Delete will be desired in the displays
as well as the rest of the application implementation.

## WABuR Components and Terminology

WABuR is designed as a Model View Controller (MVC) system. At the core is a
Ruby Controller that executes the business logic of the app. The Controller
resides on the server side. To support the Controller an HTTP web server and a
DataBase are needed. This is provided by a Runner and Shell combination as
denoted in the WAB Components diagram. The view aspect of the MVC is provides
on the client side in a browser. The View is implemented with JavaScript. The
JavaScript esentially implements a separate display application that interacts
with the Controller with messages exchanged through the HTTP server and
conforming to a defined API.

The WAB architecture allows for replacement of multiple parts of the system
without changing the code of other parts. For example, the View code could be
replaced by a completely differen custom JavaScript implmentation. A CLI could
even be implement to interact with the Controller through a Runner with not
changes to the server side. Multiple View implemenation could even be run at
the same time. Additionally, as will be seen in later lessons, the Runner and
Shell can be swapped out for alternatives that are have higher performance
characteristics and use a different storage mechanism.

![](wab_parts.svg)

The design pattern used for the WABuR reference implementation utilizes a REST
based API. This matches well with the object based approach to the design and
to storage of data, not as tables, rows, and columns but as JSON records which
encapsulate the data of the objects being stored. A REST API encourages the
use of an object based set od displays so in the reference WABuR View
implemenation each display is backed by either a single object or in the case
of lists a set of objects.

The use of the term 'display' is similar to what many might think of as a page
on a web site. Page is not exactly correct for the View though as the View is
implemented as a single page that frames a display area. That display area is
where the JavaScript code displays the content of each psuedo page which is
referred to a a display in this tutorial.

On the modeling side, storing any JSON record is possible but not very helpful
when using a class based API. To resolve this issue the reference
implemenation enforces the addition of an object class stored in the JSON
records in the 'kind' field. That can be changed but the default is 'kind'. As
an example, for an Entry with a title and content attribute the JSON stored
would look like:

```javascript
{
  "kind": "Entry",
  "title": "First Entry",
  "content": "Just saying hello!"
}
```

Other than in the View there is no need to know what the JSON looks like but
it is a convenient way to describe the structure of the object.

## Development Environment

For development the pure Ruby Runner and Shell are used. The pure Ruby Runner
is in the bin directory and is named `wabur`. A browser will also be needed to
test the View or UI. Rounding out the environment would be a test directory
for writing unit tests. The WABuR design makes it easy to write unit tests on
the Controller. The Controller interface is limited and well defined. Moving
up from testing the Controller by itself the Controller inside a Runner can be
tested using 'curl' which makes testing the server side possible in a
continuous integration suite.

## File and Directory Organization

The files for this lesson are in the `lesson-1/app` directory. The directory
is laid out as indicated in three subdirectories.

The `conf` subdirectory is where Runner configuration files are placed. For
lesson one the `wabur` Runner is used so that is the only conf file in the
directory.

The `lib` subdirectory is for Ruby code. It contains a basic Controller that
handles all REST calls using the default behavior.

Content that is served to the clients in response to HTTP page requests are in
the `pages` subdirectory. The only two files needed are a simple index file
that identifies the element to use for display and a configuration
file. Details of each are explained in more details later.

```
app
  conf
    wabur.conf
  lib
    entry_controller.rb
  pages
    conf.js
    index.html
```

## Implementation

The order of the steps in this portion of the lesson follow the files used to
implement the web application. Each file contents are explained after showing
the file.

### entry_controller.rb

A good place to start the implementation is with the business logic in the
Controller Ruby file, `entry_controller.rb`. Since there is only one object
type the controller is set up just for that object type but the exact same
file could be used for other object types as well.

```ruby
require 'wab'

class EntryController < WAB::Controller

  def initialize(shell)
    super(shell)
  end

  def handle(_data)
    raise NotImplementedError.new
  end

  def create(path, query, data)
    super
  end

  def read(path, query)
    super
  end

  def update(path, query, data)
    super
  end

  def delete(path, query)
    super
  end

end
```

The `entry_controller.rb` start by requiring the WAB module. Below that is a
class definition for a subclass of the `WAB::Controller` class. All
Controllers should inherit from the WAB::Controller class although as long as
the class implements all the methods shown the class it can be used.

This controller exposes all possible methods expected in a WAB::Controller
subclass, as public methods. Since those methods are private in the
superclass, they need to be redefined as public methods to enable the
concerned functionality.

For example, if a controller is intented to provide only read-access, then
just the `read` method would need to be exposed as a public method. The
remaining methods may remain private.

The `handle` method is used to catch requests that are not one of the below
methods. Since no behavior other than REST calls are needed for this sample,
the `handle` method raises an exception.

Thats it for the Controller as the default behavior is the desired
behavior. The objects stored in the database are the same as those provided to
the View. Note the objects are strictly data or more accurately
WAB::Data. They should never be monkey-patched. If additional behavior is
desired then helpers or delgates should be used instead.

More details on the expected behavior of the methods can be found in the
documenation for WAB::Controller class.

### index.html

The `index.html` provides is a simple one.

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Welcome to WABuR Tutorial Lesson One</title>
    <link rel="stylesheet" type="text/css" media="screen, print" href="http://www.wab.systems/ref/v0.7.0/assets/css/wab.css" />
    <link rel="stylesheet" type="text/css" media="screen, print" href="http://www.wab.systems/ref/v0.7.0/assets/wabfont/style.css" />
  </head>
  <body>
    <header class="header">
      <div class="logo">
        <span class="brand">WABuR</span>
        <span class="subtitle">Web Application Builder using Ruby</span>
      </div>
      <nav class="navbar">
        <ul>
          <li><a href="#">About</a></li>
          <li><a href="https://github.com/ohler55/wabur">Contribute</a></li>
        </ul>
      </nav>
    </header>

    <main class="content">
      <div id="view" class="view-content">
      </div>
    </main>

    <footer class="footer">
      <div class="attribution">
        Powered by <a class="brand" href="https://github.com/ohler55/wabur">WABuR</a>
      </div>
    </footer>

    <script src="http://www.wab.systems/ref/v0.7.0/assets/js/wab.js"></script>
    <script src="conf.js"></script>
  </body>
</html>
```

The `index.html` files is a basic HTML file. The key points are the links in
the head that pull in the stylesheets from the WAB release. Note that version
in the URL should be to the latest release instead of the shown URL.

The second important part of the HTML is the inclusion of a `div` that has an
id of `view`. This is used by the JavaScript to determine where it should
manage elements.

To initialize the WAB reference inplementation JavaScript the URL to the
`wab.js` file must be included. Following the loading of the `wab.js` the
`conf.js` file should be loaded.

### conf.js

** TBD is it worth making a default REST flow or sub-flow for a kind? **

```
entryFlow = wab.makeRestFlow('Entry')
```

*********************************************

The `conf.js` file is a JavaScript file but it is only used for declarations
and setting up a configuration that is passed to the wab module using the
`wab.setFlow` function. The file show is a minimal version. More options are
available and will be described in a future lesson.

The view configuration describes individual displays as well as what actions
cause a change in the display. After that it is left up to the wab module to
run the show.

```
entryList = {
    elements: {
        null: {
            display_class: wab.List,
            config: {
                kind: 'Entry',
                fields: [ 'title' ]
            },
            actions: {
                createButton: 'entryCreate',
                viewButton: 'entryView',
                editButton: 'entryView',
                deleteButton: 'entryList'
            }
        }
    }
}

entryCreate = {
    elements: {
        one: {
            display_class: wab.Create,
            config: {
                fields: [ 'title', 'content' ]
            },
            actions: {
                saveButton: 'entryView',
                cancelButton: 'entryList'
            }
        }
    }
}

entryView = {
    elements: {
        one: {
            display_class: wab.View,
            config: {
                fields: [ 'title', 'content' ]
            },
            actions: {
                lockButton: 'entryEdit'
            }
        }
    }
}

entryEdit = {
    elements: {
        one: {
            display_class: wab.Edit,
            config: {
                fields: [ 'title', 'content' ]
            },
            actions: {
                lockButton: 'entryView',
                saveButton: 'entryView',
                deleteButton: 'entryList'
            }
        }
    }
}

flow = {
    initial: 'entryList',
    displays: {
        entryList: {
            display: entryList,
        },
        entryCreate: {
            display: entryCreate
        },
        entryView: {
            display: entryView
        },
        entryEdit: {
            display: entryEdit
        }
    }    
}

wab.setFlow(flow);
```

The view specification is composed of individual display specification as well
as a flow that ties all the separate displays together. The tying together of
the separate displays is similar to a process flow diagram. Individual
displays are analogous tasks in a process flow and the process flow
transitions are the same as actions taken on events that cause the displays to
transition from one to another.

The UI flow is specified by a single JSON Object where each key of the object
identifies display and the displays are described by another JSON Object. To
better organize this structure the display specification are described first
and then a flow ties the displays together.

First the individual displays are defined. Each of the
displays will become an element in the HTML element with an id of `view`.

Looking at a display description such as the `entryCreate` there is an
attribute name `elements` that has one or more attributes that describe the
elements in the display. There is only one in this case with an index of
`one`. When there is only one element and no layout manager defined any name
will do.

Within the `elements` single attribute there are three attributes,
`display_class`, `config`, and `actions`. The `display_class` identifies the
JavaScript object to use for the display. The wab module has several built in
classes for list, create, edit, and view. These objects have defaults for the
expected REST behavior. Each has it's own set of actions that can trigger
transitions. The transitions occur after the object takes the default action.

The actions element describes which transition to take for supported events on
the `display_class`. In the case of the wab.List, three buttons events are
supported. The actions are hardcoded and the action will take place after the
hardcoded action. If the button has no action then it is not displayed. If not
null then a description of the display to transition to should be provided or
a key in the flow description can be used instead.

The `config` element includes configuration information specific to the
display type. For the `wab.Create` display class a list of fields that the
user can enter data into is listed. In the simple cas just the field names are
given and a text field is assumed.

The flow variable defines what displays are available and associates them with
name so that the actions defined early can lookup the correct display if a
string identifier was used. It also specifies the initial display to show the
user.

### wabur.conf

Each Runner has it's own specific configuration options. Each Runner is
different so each Runner configuration file has different options.

```
# wabur.conf

dir = app/data/wabur
handler.path = /v1
controller = EntryController
http.port = 6363
http.dir = app/pages
```

The file format follows the Unix configuration file common to most Unix
applications. The first option is the `dir` which identifies where the wabur
Runner should store data. In the case of wabur the data will be JSON
files. One fiel for each record with the filename being the object reference
identifier.

The `handler.path` is the path prefix for the HTTP server. This is similar to
a route so `/v1/Entry/123` in a GET request would return the JSON record for
Entry 123.

The `controller` is the controller class to create an instance of. wabur must
be started with the correct load paths and requires to allow the Controller
class to be created.

An HTTP port and page directory are needed to allow the pages created for this
lesson to be loaded.

## Running

- run
 - config runner
 - try it

## Testing

- unit tests (should be done earlier but it is a quick start)
 - controller
 - with runner

