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
    },
    // The act attribute is an enum value 0=view, 1=edit, 3=delete
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
    console.log("deleting " + ref);
    httpDelete('/v1/' + this.kind + '/' + ref, this, function(ol, resp) {
        // TBD this is probably a better way to do this.
        wab.view.set(ol);
    })
}

wab.ObjList.prototype.display = function(view, edit) {

    // TBD add a Create button

    var frame = document.createElement('table'), list, row, cell;
    frame.className = 'obj-list-table';
    view.appendChild(frame);

    row = document.createElement('tr');
    frame.appendChild(row);
    cell = document.createElement('td');
    row.appendChild(cell);

    header = document.createElement('table');
    header.className = 'obj-list-table';
    cell.appendChild(header);

    row = document.createElement('tr');
    header.appendChild(row);

    var i, cs = this.spec.list, len = cs.length;
    for (i = 0; i < len; i++) {
        cs = this.spec.list[i];
        cell = document.createElement('th');
        if (3 <= cs.length) {
            cell.style.width = cs[2];
        } else {
            cell.style.width = 'auto';
        }
        cell.appendChild(document.createTextNode(cs[0]));
        row.appendChild(cell);
    }
    cell = document.createElement('th');
    cell.appendChild(document.createTextNode('Actions'));
    cell.style.width = '196px'; // TBD use a css style instead
    //cell.className = 'obj-list-table ???';
    row.appendChild(cell);

    // Prepare list table.
    row = document.createElement('tr');
    frame.appendChild(row);
    cell = document.createElement('td');
    row.appendChild(cell);
    list = document.createElement('table');
    list.className = 'obj-list-table';
    cell.appendChild(list);

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
                    if (3 <= cs.length) {
                        cell.style.width = cs[2];
                    } else {
                        cell.style.width = 'auto';
                    }
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
                            break;
                        }
                    })(ol, ref, btn, bi.act);
                    row.appendChild(cell);
                }
            }
        }
    })
}

wab.Obj.prototype.display = function(view, edit) {
    var frame = document.createElement('div'), form, input, row, cell;
    frame.className = 'obj-form-frame';
    view.appendChild(frame);


    // Lock icon set according to edit flag, add click to flip from edit to view.
    var p = document.createElement('p'), btn = document.createElement('span');
    // TBD fix this once there are icons for locked and unlocked
    if (edit) {
        p.appendChild(document.createTextNode('unlocked'));
    } else {
        p.appendChild(document.createTextNode('locked'));
    }
    //btn.className = 'icon-form-locked';
    //btn.setAttribute('title', 'locked');
    //p.appendChild(btn);
    frame.appendChild(p);
    // TBD add onclick toggle of locked to flip between edit and view


    // A table aligns the labels nicely.
    form = document.createElement('table');
    form.className = 'obj-form';
    frame.appendChild(form);

    // Layout the attribute fields first then request the data or populate with defaults.
    var fields = this.spec.obj.fields, i, f, flen = fields.length;

    for (i = 0; i < flen; i++) {
        f = fields[i];
        row = document.createElement('tr');
        form.appendChild(row);
        cell = document.createElement('td');
        cell.appendChild(document.createTextNode(f.label));
        row.appendChild(cell);
        cell = document.createElement('td');
        if ('textarea' == f.type) {
            input = document.createElement('textarea');
            if (undefined != f.cols) {
                input.setAttribute('cols', '' + f.cols);
            }
            if (undefined != f.rows) {
                input.setAttribute('rows', '' + f.rows);
            }
            input.value = f.init;
        } else if (typeof f.init === 'object') {
            // TBD handle nested values
        } else {
            input = document.createElement('input');
            input.setAttribute('type', f.type);
            input.setAttribute('value', f.init);
        }
        if (undefined != f.width) {
            input.style.width = f.width;
        }
        if (undefined != f.height) {
            input.style.heigth = f.height;
        }
        if (!edit) {
            input.readOnly = true;
        }
        input.setAttribute('path', f.path);
        cell.appendChild(input);
        row.appendChild(cell);
    }
    p = document.createElement('p');
    // TBD change this to the correct type for a button
    if (0 != this.ref) {
        p.appendChild(document.createTextNode('Update'));
    } else {
        p.appendChild(document.createTextNode('Create'));
    }
    frame.appendChild(p);
    // TBD add onclick toggle of locked to flip between edit and view


    this.form = form;
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
