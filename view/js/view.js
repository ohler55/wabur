// View methods.
wab.View.prototype.register_type = function(kind, spec) {
    this.specs[kind] = spec;
}

wab.View.prototype.set = function(page, edit) {
    // Clear out any existing elements in the view.
    var types = document.getElementById("types"), child;
    while (null != (child = this.view.firstChild)) {
        this.view.removeChild(child);
    }
    while (null != (child = types.firstChild)) {
        types.removeChild(child);
    }
    // Display types in sidebar with the title associated with the page type
    // highlighted.
    var page_kind = '';
    this.page = page;
    if (null != page) {
        page.display(this.view, edit);
        page_kind = page.kind;
    }
    Object.keys(wab.view.specs).sort().forEach(function(k, i) {
        title = document.createElement('li');
        if (page_kind == k) {
            title.className = 'sidebar_selected';
        } else {
            title.className = 'sidebar_item';
        }
        types.appendChild(title);
        title.appendChild(document.createTextNode(k));
        title.onclick = function() {
            wab.view.set(new wab.ObjList(k, wab.view.specs[k]));
        }
    });
}

wab.view = new wab.View();
