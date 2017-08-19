// The wab namespace and constructor definitions. Everything is in this file
// to minimize page fetchs from the server.

var wab = {
    View: function() {
        this.view = document.getElementById("view");
        this.page = null;
        this.specs = {};
    },
    TypeList: function TypeList() {
    },
    ObjList: function ObjList(kind, spec) {
        this.kind = kind;
        this.spec = spec;
    }
}

// View methods.
wab.View.prototype.register_class = function(kind, spec) {
    this.specs[kind] = spec;
}

wab.View.prototype.set = function(page, edit) {
    if (null == page) {
        page = new wab.TypeList();
    }
    // Clear out any existing elements in the view.
    var child;
    while (null != (child = this.view.firstChild)) {
        this.view.removeChild(child);
    }
    this.page = page;
    page.display(this.view, edit);
}

wab.ObjList.prototype.display = function(view, edit) {
    var p = document.createElement('p');
    p.className = 'list_title';
    p.appendChild(document.createTextNode('All ' + this.kind + ' records'))
    view.appendChild(p);

    var list = document.createElement('div'), row;
    list.className = 'list';
    view.appendChild(list);

    // TBD request all of this.kind, callback should add the elements to the display or show an error
}

wab.TypeList.prototype.display = function(view, edit) {
    var p = document.createElement('p');
    p.className = 'list_title';
    p.appendChild(document.createTextNode('Types'))
    view.appendChild(p);

    var list = document.createElement('div'), row;
    list.className = 'list';
    view.appendChild(list);
    
    Object.keys(wab.view.specs).sort().forEach(function(k, i) {
        row = document.createElement('div');
        row.className = 'list_row';
        list.appendChild(row);

        p = document.createElement('p');
        p.className = 'list_cell';
        p.appendChild(document.createTextNode(k));
        p.onclick = function() {
            wab.view.set(new wab.ObjList(k, wab.view.specs[k]));
        }
        row.appendChild(p);
    });
}

wab.view = new wab.View();
