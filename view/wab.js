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
    }
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

wab.ObjList.prototype.display = function(view, edit) {

    // TBD add a Create button

    var frame = document.createElement('table'), list, row, cell;
    frame.className = 'obj-list-frame';
    view.appendChild(frame);

    row = document.createElement('tr');
    frame.appendChild(row);
    cell = document.createElement('td');
    row.appendChild(cell);

    header = document.createElement('table');
    header.className = 'obj-list-header';
    cell.appendChild(header);

    row = document.createElement('tr');
    header.appendChild(row);

    var i, cs = this.spec.list, len = cs.length;
    for (i = 0; i < len; i++) {
        cs = this.spec.list[i];
        cell = document.createElement('td');
        cell.className = 'obj-list-header';
        if (3 <= cs.length) {
            cell.style.width = cs[2];
        } else {
            cell.style.width = 'auto';
        }
        cell.appendChild(document.createTextNode(cs[0]));
        row.appendChild(cell);
    }
    cell = document.createElement('td');
    cell.className = 'obj-header-button';
    row.appendChild(cell);
    
    cell = document.createElement('td');
    cell.className = 'obj-header-button';
    row.appendChild(cell);

    cell = document.createElement('td');
    cell.className = 'obj-header-button';
    row.appendChild(cell);

    // Prepare list table.
    row = document.createElement('tr');
    frame.appendChild(row);
    cell = document.createElement('td');
    row.appendChild(cell);
    list = document.createElement('table');
    list.className = 'obj-list';
    cell.appendChild(list);

    this.list = list;
    
    // Request content.
    httpGet('/v1/' + this.kind, this, function(ol, resp) {

        // TBD change query to be Article/list&select=title;text or Article/_select=title;text

        var results = resp.body.results;

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
                cell = document.createElement('td');
                cell.className = 'obj-list-button';
                cell.appendChild(document.createTextNode('View'));
                // TBD add onclick with ref
                row.appendChild(cell);
                
                cell = document.createElement('td');
                cell.className = 'obj-list-button';
                cell.appendChild(document.createTextNode('Edit'));
                // TBD add onclick with ref
                row.appendChild(cell);

                cell = document.createElement('td');
                cell.className = 'obj-list-button';
                cell.appendChild(document.createTextNode('Delete'));
                // TBD add onclick with ref
                row.appendChild(cell);
            }
        }
    })
}

wab.view = new wab.View();
