// The wab namespace and constructor definitions. Everything is in this file
// to minimize page fetchs from the server.

var wab = {
    View: function() {
        this.view = document.getElementById("view");
        this.page = null;
        this.specs = {};
    },
    ObjList: function ObjList(kind, spec) {
        this.kind = kind;
        this.spec = spec;
    },
    Obj: function Obj(ref, spec) {
        this.ref = ref;
        this.spec = spec;
        this.form = null;
        this.lock = null;
        this.edit = false;
        this.save_button = null;
    },
    // The act attribute is an enum value 0=view, 1=edit, 2=delete
    list_buttons: [
        { title: 'View', icon: 'icon icon-eye', cn: 'actions', act: 0 },
        { title: 'Edit', icon: 'icon icon-pencil', cn: 'actions', act: 1 },
        { title: 'Delete', icon: 'icon icon-trash-o', cn: 'actions delete', act: 2 }
    ]
}

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

function httpGet(url, obj, cb) {
    var h = new XMLHttpRequest();
    h.open('GET', url, true);
    h.responseType = 'json';
    h.onreadystatechange = function() {
        if (4 == h.readyState) {
            if (200 == h.status) {
                cb(obj, h.response);
            } else {
                alert('Query to ' + url + ' returned ' + h.status + '.');
            }
        }
    };
    h.send();
}

function httpDelete(url, obj, cb) {
    var h = new XMLHttpRequest();
    h.open('DELETE', url, true);
    h.responseType = 'json';
    h.onreadystatechange = function() {
        if (4 == h.readyState) {
            if (200 == h.status) {
                cb(obj, h.response);
            } else {
                alert('Delete to ' + url + ' returned ' + h.status + '.');
            }
        }
    };
    h.send();
}

wab.ObjList.prototype.delete = function(ref) {
    httpDelete('/v1/' + this.kind + '/' + ref, this, function(ol, resp) {
        // TBD this is probably a better way to do this.
        wab.view.set(ol);
    })
}

wab.ObjList.prototype.display = function(view, edit) {

    // TBD add a Create button

    var wrapper = document.createElement('div');
    wrapper.className = 'table-wrapper';
    view.appendChild(wrapper);

    var frame = document.createElement('table'), list, row, cell;
    wrapper.appendChild(frame);

    row = document.createElement('tr');
    frame.appendChild(row);


    header = document.createElement('table');
    header.className = 'obj-list-table';
    row.appendChild(header);

    row = document.createElement('tr');
    header.appendChild(row);

    var cs = this.spec.list, len = cs.length;
    for (i = 0; i < len; i++) {
        cs = this.spec.list[i];
        cell = document.createElement('th');
        cell.appendChild(document.createTextNode(cs[0]));
        row.appendChild(cell);
    }
    cell = document.createElement('th');
    cell.appendChild(document.createTextNode('Actions'));
    cell.className = 'list-actions';
    cell.setAttribute('colspan', 3);
    row.appendChild(cell);

    // Prepare list table.
    row = document.createElement('tr');
    row.className = 'list-items';
    frame.appendChild(row);
    list = document.createElement('table');
    list.className = 'obj-list-table';
    row.appendChild(list);

    this.list = list;
    
    // Request content.
    httpGet('/v1/' + this.kind, this, function(ol, resp) {

        // TBD change query to be Article/list&select=title;text or Article/_select=title;text

        var results = resp.body.results, btn, bi;
        
        if (typeof results === 'object') {
            var i, cs = ol.spec.list, len = cs.length;
            var j, obj, rlen = results.length, ref;
            for (j = 0; j < rlen; j++) {
                obj = results[j];
                ref = obj.id;
                obj = obj.data;
                row = document.createElement('tr');
                ol.list.appendChild(row);
                for (i = 0; i < len; i++) {
                    cs = ol.spec.list[i];
                    cell = document.createElement('td');
                    cell.className = 'obj-list';
                    cell.appendChild(document.createTextNode(obj[cs[1]]));
                    row.appendChild(cell);
                }
                for (i = 0; i < wab.list_buttons.length; i++) {
                    bi = wab.list_buttons[i];
                    cell = document.createElement('td');
                    cell.className = bi.cn;
                    btn = document.createElement('span');
                    btn.className = bi.icon;
                    btn.setAttribute('title', bi.title);
                    cell.appendChild(btn);
                    // A function is needed to copy the variables.
                    (function(ol, r, b, act) {
                        switch(act) {
                        case 2:
                            b.onclick = function() { ol.delete(r); }
                            break;
                        case 1:
                            b.onclick = function() { wab.view.set(new wab.Obj(r, ol.spec), true); }
                            break;
                        case 0:
                        default:
                            b.onclick = function() { wab.view.set(new wab.Obj(r, ol.spec), false); }
                        }
                    })(ol, ref, btn, bi.act);
                    row.appendChild(cell);
                }
            }
        }
    })
}

wab.Obj.prototype.toggleLock = function() {
    this.edit = !this.edit;
    var child, i, j, row, cell, input;
    while (null != (child = this.lock.firstChild)) {
        this.lock.removeChild(child);
    }
    if (this.edit) {
        this.lock.className = 'icon icon-unlock';
        this.lock.setAttribute('title', 'unlocked');
    } else {
        this.lock.className = 'icon icon-lock';
        this.lock.setAttribute('title', 'locked');
    }
    for (i = this.form.children.length - 1; 0 <= i; i--) {
        row = this.form.children[i];
        for (j = row.children.length - 1; 0 <= j; j--) {
            cell = row.children[j];
            input = cell.firstChild;
            if ('INPUT' == input.nodeName || 'TEXTAREA' == input.nodeName) {
                input.readOnly = !this.edit;
            }
            // TBD handle nested
        }
    }
    if (this.edit) {
        // TBD set style
        (function(o) { o.save_button.onclick = function() { o.save(); }})(this);
    } else {
        // TBD set style
        (function(o) { o.save_button.onclick = function() { }})(this);
    }
    // TBD should modified values be flipped back to the originals?
}

wab.Obj.prototype.save = function() {
    console.log("Save clicked for " + this.ref + ' - locked: ' + !this.edit);
    // TBD
}

wab.Obj.prototype.display = function(view, edit) {
    this.edit = edit;
    var frame = document.createElement('div'), form, input, row, cell;
    frame.className = 'obj-form-frame';
    view.appendChild(frame);

    // Lock icon set according to edit flag, add click to flip from edit to view.
    var e = document.createElement('div'), btn = document.createElement('span');
    e.className = 'btn lock-btn';
    this.lock = btn;
    if (edit) {
        btn.className = 'icon icon-unlock';
        btn.setAttribute('title', 'unlocked');
    } else {
        btn.className = 'icon icon-lock';
        btn.setAttribute('title', 'locked');
    }
    e.appendChild(btn);
    frame.appendChild(e);
    (function(o) { e.onclick = function() { o.toggleLock(); }})(this);

    // A table aligns the labels nicely.
    form = document.createElement('table');
    this.form = form;
    form.className = 'obj-form';
    frame.appendChild(form);

    // Layout the attribute fields first then request the data or populate with defaults.
    var fields = this.spec.obj.fields, i, f, flen = fields.length;

    for (i = 0; i < flen; i++) {
        f = fields[i];
        row = document.createElement('tr');
        form.appendChild(row);
        cell = document.createElement('td');
        cell.className = 'field-label';
        cell.appendChild(document.createTextNode(f.label));
        row.appendChild(cell);
        cell = document.createElement('td');
        if ('textarea' == f.type) {
            input = document.createElement('textarea');
            input.className = 'form-field';
            input.value = f.init;
        } else if (typeof f.init === 'object') {
            // TBD handle nested values
        } else {
            input = document.createElement('input');
            input.className = 'form-field';
            input.setAttribute('type', f.type);
            input.setAttribute('value', f.init);
        }
        if (!edit) {
            input.readOnly = true;
        }
        input.setAttribute('path', f.path);
        cell.appendChild(input);
        row.appendChild(cell);
    }
    e = document.createElement('div');
    e.className = 'btn';
    btn = document.createElement('span');
    this.save_button = e;
    // TBD change this to the correct type for a button
    if (0 != this.ref) {
        btn.appendChild(document.createTextNode('Update'));
    } else {
        btn.appendChild(document.createTextNode('Create'));
    }
    if (edit) {
        // TBD set style
        (function(o) { e.onclick = function() { o.save(); }})(this);
    } else {
        // TBD set style
        (function(o) { e.onclick = function() { }})(this);
    }
    e.appendChild(btn);
    frame.appendChild(e);

    if (0 != this.ref) {
        httpGet('/v1/' + this.spec.obj.kind + '/' + this.ref, this, function(o, resp) {
            if (0 != resp.body.code) {
                alert(results.error);
                return;
            }
            var results = resp.body.results;
            if (!(typeof results === 'object')) {
                alert('Invalid response from server');
                return;
            }
            if (0 == results.length) {
                alert('Record not found.');
                return;
            }
            var obj = results[0].data, i, j, row, cell, input;
            for (i = o.form.children.length - 1; 0 <= i; i--) {
                row = o.form.children[i];
                for (j = row.children.length - 1; 0 <= j; j--) {
                    cell = row.children[j];
                    input = cell.firstChild;
                    if ('INPUT' == input.nodeName) {
                        input.setAttribute('value', obj[input.getAttribute('path')]);
                    } else if ('TEXTAREA' == input.nodeName) {
                        input.value = obj[input.getAttribute('path')];
                    }
                    // TBD handle nested
                }
            }
        })
    }
}

wab.view = new wab.View();
