
# WABuR Tutorial Lesson 1

This first lesson of the WABuR Tutorial covers.

 - [Application Design](#application-design)
 - [WABuR Components and Terminology](#wabur-components-and-terminology)
 - [Development Environment](#development-environment)
 - [File and Directory Organization](#file-and-directory-organization)
 - [Implementation](#implementation)
 - [Running](#running)

## Application Design

The first step in building any application is deciding what to build. WABuR or
simply WAB will follow an object based design. With that in mind, building a
blog will require blog entries so an Entry will be the primary object-type in
the application.

An Entry will initially have two attributes, a **title** and
**content**. Later more attributes will be added but initially, those two
attributes will be sufficient. The canonical data representation is JSON so in
this tutorial JSON will be used to describe objects and data.

For the blog a list of Entries is desired. Additionally, the standard CRUD
operations of Create, Read, Update, and Delete will be desired in the displays
as well as the rest of the application implementation.

## WABuR Components and Terminology

WABuR is designed as a Model View Controller (MVC) system. At the core is a
Ruby Controller that executes the business logic of the app. The Controller
resides at the server-side. To support the Controller, an HTTP web server and
a Database are needed. This is provided by the Runner-Shell combination as
denoted in the WAB Components diagram. The view aspect of the MVC pattern here
is a JavaScript implementation at the client-side in a browser.  JavaScript
essentially implements a separate display application that interacts with the
Controller with messages that are exchanged via the HTTP server conforming to
a defined API.

The WAB architecture allows for replacement of multiple parts of the system
without changing the code of other parts. For example, the View component
could be replaced by a completely different custom JavaScript
implementation. A CLI could even be implemented to interact with the
Controller through a Runner with no changes to the server-side. Multiple View
implementation could even be run at the same time. Additionally, as will be
seen in later lessons, the Runner and Shell can be swapped out for
alternatives that are have higher performance characteristics and use a
different storage mechanism. The Runner and Shell form the server side of the
application while HTML, CSS, and JavaScript form the client side. Since the
server does provide the files to the client there is some breakdown in the
separation but Ruby files devoted to the View or UI are strictly for
generating the HTML and Javascript for the UI.

![](wab_parts.svg)

The design pattern used for the WABuR reference implementation utilizes a REST
based API. This matches well with the object-based approach to the design and
to storage of data, not as tables, rows, and columns but as JSON records which
encapsulate the data of the objects being stored. A REST API encourages the
use of an object based set of displays so in the reference WABuR View
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
is in the `bin` directory and is named `wabur`. A browser will also be needed
to test the View or UI. Rounding out the environment would be a test directory
for writing unit tests. The WABuR design makes it easy to write unit tests on
the Controller. The Controller interface is limited and well defined. Moving
up from testing the Controller by itself the Controller inside a Runner can be
tested using 'curl' which makes testing the server side possible in a
continuous integration suite. For this lesson only a UI Ruby file will be
needed along with a simple HTML index file.

## File and Directory Organization

The files for this lesson are in the `lesson-1/app` directory. The directory
is laid out as indicated in sub-directories.

The `lib` sub-directory is for Ruby code. It contains a basic Controller that
handles all REST calls using the default behavior.

Content that is served to the clients in response to HTTP page requests are in
the `pages` sub-directory. The only file needed is a simple index file that
identifies the element to use for display. Details are explained later.

```
app
├── lib
|   └── ui
|       └── entry.rb
└── pages
    └── index.html
```

## Implementation

- MVC
- just two files needed, one for describing the UI in Ruby and one for th epage layout
- M - built into the runner WAB::Impl::Shell & Model
- C - OpenController
- V - index.html and entry_ui.rb

--- TBD ----------------------------------------------------------------------

The order of the steps in this portion of the lesson follow the files used to
implement the web application. Each file-contents are explained after showing
the file.

### entry_controller.rb

A good place to start the implementation is with the business logic in the
Controller Ruby file, `entry_controller.rb`. Since there is only one object
type, the controller is set up just for that object type but the exact same
file could be used for other object types as well.


The `entry_controller.rb` start by requiring the `WAB` module. Below that is a
class definition for a subclass of the `WAB::Controller` class. All
Controllers should inherit from the WAB::Controller class although as long as
the class implements all the methods shown the class it can be used.

This controller exposes all possible methods expected in a `WAB::Controller`
subclass, as public methods. Since those methods are private in the
super-class, they need to be redefined as public methods to enable the
concerned functionality.

For example, if a controller is intended to provide only read-access, then
just the `read` method would need to be exposed as a public method. The
remaining methods may remain private.

The `handle` method is used to catch requests that are not one of the below
methods. Since no behavior other than REST calls are needed for this sample,
the `handle` method raises an exception.

That's it for the Controller as the default behavior is the desired
behavior. The objects stored in the database are the same as those provided to
the View. Note the objects are strictly data or more accurately
WAB::Data. They should never be monkey-patched. If additional behavior is
desired then helpers or delgates should be used instead.

More details on the expected behavior of the methods can be found in the
documentation for WAB::Controller class.

### index.html

The `index.html` provided is a simple one.

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Welcome to WABuR Tutorial Lesson One</title>
    <link rel="stylesheet" type="text/css" media="screen, print" href="http://www.wab.systems/ref/latest/assets/css/wab.css" />
    <link rel="stylesheet" type="text/css" media="screen, print" href="http://www.wab.systems/ref/latest/assets/wabfont/style.css" />
  </head>
  <body>
    <main class="content">
      <div id="view" class="view-content">
      </div>
    </main>

    <script src="http://www.wab.systems/ref/v0.7.0/assets/js/wab.js"></script>
    <script src="conf.js"></script>
  </body>
</html>
```

The `index.html` files is a basic HTML file. The links in the head pull
in the stylesheets from the WAB release.

The second important part of the HTML is the inclusion of a `div` that has an
id of `view`. This is used by the JavaScript to determine where it should
manage elements.

To initialize the WAB reference implementation JavaScript the URL to the
`wab.js` file must be included. Following the loading of the `wab.js` the
`conf.js` file should be loaded.

### conf.js

The `conf.js` file is a JavaScript file but it is used for declarations and
setting up a configuration that is passed to the wab module using the
`wab.setFlow` function. The file show is a minimal version. More options are
available and will be described in a future lesson.

The view configuration describes individual displays as well as what actions
cause a change in the display. After that it is left to the `wab` JS module to
run the show. The most basic way to create a configuration for a class that
follows a REST API is to use the `wab.makeRestFlow()`. This function expects a
sample of the class to be managed. The sample should have the default values
for each attribute.

```javascript
entrySample = {
    kind: 'Entry',
    title: '',
    content: '\n\n\n\n'
}
entryFlow = wab.makeRestFlow(entrySample)
wab.setFlow(entryFlow);
```

Note the use of multiple newline characters in the `content` attribute default
value. Each newline represents a new line in a textarea otherwise a string is
assumed to be a text field.

The `wab.makeRestFlow()` returns a default REST flow that can be used to
`wab.setFlow()`. It can also be combined in a larger flow if there are
additional displays in the application. The `wab.makeRestFlow()` function is
not required but is a helper function. We will see in a future lesson how to
grab the contents that are returned and make a custom flow and set of display
descriptions.

The flow of the application is depicted in the Entry Flow diagram. The boxes
in the diagram represent the displays and the named transitions between
displays correspond to the actions that can be taken in each display by pushing
a button. Each display shown is one of the built in WAB reference
implementation displays.

![](entry_flow.svg)

## Running

- TBD use command line options to specify the UI and Controller classes along with the data directory

The `wabur` Runner is used for this lesson. To start the Runner, the wabur gem
must be installed or the wabur source must be available. Assuming the gem is
installed and the run location is in the `lesson-1` directory the command to
run the application is:

```
> wabur -I app/lib --controller WAB::OpenController --ui UI::Entry --http.dir app/pages --data.dir app/data/wabur
```

That will start the Runner listening on port 6363 and storing data in the
`app/data/wabur` directory. Open a browser and type in `http://localhost:6363` and
observe an empty blog entry list. Use the `Create` button to create a new Entry
and the other displays and buttons to experience the new application.
