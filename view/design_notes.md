
# WAB View Design Notes

The view Javascript will be plain Javascript and not pull in frameworks such
as React or Node.js.

It will follow an object oriented approach using Javascript prototypes.

It will use a wab namespace.

```
wab = {
  function Obj(kind, template) {
  }
  this.Obj = Obj;
}
```

The architecture is of a single home page that loads up all the Javascript
files and runs as an application sending and receiving data from the WAB
Runner on a server. The top level object is an instance of wab.View. The home
page provides a conceptual frame around the application and also initializes
the was.View with information about the classes being served and started with
a wab.ClassList page.

The wab.View displays wab.Page instances such as wab.Show or wab.Edit which
are generics. Usually those are subclassed to something like Article.

```
function Article() {
  template = { 'title': '', 'text': '' };
  wab.Obj.call(this, 'article', template);
}

Article.prototype = Object.create(wab,Obj.prototype);
Article.prototype.constructor = Article;
```

The template can be either a sample of the class instances with default values
or later specs can be used instead of default values. That is the second round
of the view development.

wab.List will show some set of fields in each object along with operations
buttons for show, edit, and delete.

wab.Obj is for displaying a single object. It includes a switch for view only
or edit mode.

```
wab.Obj.prototype.constructor = function(kind, template) {
  this.kind = kind;
  this.template = template;
}
WabObj.prototype.show = function(id_or_obj, some_display_thingy) {
  // layout template elements
  // populate
}
```

Sending messages is done with wab.Sender with responses hitting a callback on
the wab.Obj that then processes the message.

## Plan

- create view/index.html
- wab.View
- wab.Page
- wab.Obj
 - show const string first
- wab.Sender
- wab.List request and display raw JSON list
- wab.List better display
- wab.Obj handle template and display
