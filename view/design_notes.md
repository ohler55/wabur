
# WAB View Design Notes

The view Javascript will be plain Javascript and not pull in frameworks such
as React or Node.js.

It will follow an object-oriented approach using Javascript prototypes.

It will use a *`wab`* namespace.

```javascript
wab = {
  function Obj(kind, template) {
  }
  this.Obj = Obj;
}
```

The architecture is of a single home page that loads up all the Javascript
files and runs as an application sending and receiving data from the WAB
Runner on a server. The top level object is an instance of `wab.View`. The
home page provides a conceptual frame around the application and also
initializes the `was.View` with information about the classes being served.

The `wab.View` displays `wab.ObjList` or `wab.Obj` instances which are
generics. Specialized subclasses can also be made.

```javascript
function Article() {
  template = { 'title': '', 'text': '' };
  wab.Obj.call(this, 'article', template);
}

Article.prototype = Object.create(wab,Obj.prototype);
Article.prototype.constructor = Article;
```

Specifications are used to describe how lists and objects are displayed.
The spec includes default values as well as how to display those values.

`wab.ObjList` will show some set of fields in each object along with operations
buttons for `show`, `edit`, and `delete`.

`wab.Obj` is for displaying a single object. It includes a switch for `view` only
or `edit` mode.

```javascript
wab.Obj.prototype.constructor = function(kind, template) {
  this.kind = kind;
  this.template = template;
}
WabObj.prototype.display = function(id_or_obj, some_display_thingy) {
  // layout template elements
  // populate
}
```
