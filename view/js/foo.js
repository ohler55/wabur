
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
        wab.view.set(ol);
    })
}

wab.ObjList.prototype.display = function(view, edit) {
    var wrapper = document.createElement('div');
    wrapper.className = 'table-wrapper';
    view.appendChild(wrapper);

    e = document.createElement('div');
    e.className = 'btn';
    btn = document.createElement('span');
    btn.appendChild(document.createTextNode('Create'));
    (function(ol) { e.onclick = function() { wab.view.set(new wab.Obj(0, ol), true); }})(this);
    e.appendChild(btn);
    wrapper.appendChild(e);

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
                            b.onclick = function() { wab.view.set(new wab.Obj(r, ol), true); }
                            break;
                        case 0:
                        default:
                            b.onclick = function() { wab.view.set(new wab.Obj(r, ol), false); }
                        }
                    })(ol, ref, btn, bi.act);
                    row.appendChild(cell);
                }
            }
        }
    })
}

wab.Obj.prototype.fetch = function() {
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
                    if ('INPUT' == input.nodeName || 'TEXTAREA' == input.nodeName) {
                        input.value = obj[input.path];
                    }
                    // TBD handle nested
                }
            }
        })
    }
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
        this.save_button.style.visibility = 'visible';
        if (0 != this.ref) {
            this.delete_button.style.visibility = 'visible';
        }
    } else {
        this.fetch(); // refresh attributes
        (function(o) { o.save_button.onclick = function() { }})(this);
        this.save_button.style.visibility = 'hidden';
        this.delete_button.style.visibility = 'hidden';
    }
    // TBD should modified values be flipped back to the originals?
}

wab.Obj.prototype.save = function() {
    var obj = { kind: this.spec.obj.kind }, i, row, cell, input;

    for (i = this.form.children.length - 1; 0 <= i; i--) {
        row = this.form.children[i];
        for (j = row.children.length - 1; 0 <= j; j--) {
            cell = row.children[j];
            input = cell.firstChild;
            if ('INPUT' == input.nodeName || 'TEXTAREA' == input.nodeName) {
                // TBD convert to correct type
                obj[input.path] = input.value;
            }
            // TBD handle nested
        }
    }
    var method, url;
    
    if (0 == this.ref) {
        method = 'PUT';
        url = '/v1/' + this.spec.obj.kind;
    } else {
        method = 'POST';
        url = '/v1/' + this.spec.obj.kind + '/' + this.ref;
    }
    var h = new XMLHttpRequest();
    h.open(method, url, true);
    h.setRequestHeader('Content-Type', 'application/json');
    h.responseType = 'json';
    (function(o) {
        h.onreadystatechange = function() {
            if (4 == h.readyState) {
                if (200 == h.status) {
                    if (0 == o.ref) { // create
                        o.ref = h.response.body.ref
                        o.delete_button.style.visibility = 'visible';
                        o.save_button.removeChild(o.save_button.firstChild);
                        o.save_button.appendChild(document.createTextNode('Update'));
                    } else { // update
                        var updated = h.response.body.updated;
                        if (typeof updated === 'object' || 0 < updated.length) {
                            o.ref = updated[0];
                        } else {
                            alert('Save to ' + url + ' returned an a null object reference.');
                        }
                    }
                    o.fetch();
                } else {
                    alert('Save to ' + url + ' returned ' + h.status + '.');
                }
            }
        }
    })(this);
    h.send(JSON.stringify(obj));
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
            input.value = f.init;
        }
        if (!edit) {
            input.readOnly = true;
        }
        input.path = f.path;
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
    (function(o) { e.onclick = function() { o.save(); }})(this);
    if (!edit) {
        e.style.visibility = 'hidden';
    }
    e.appendChild(btn);
    frame.appendChild(e);

    e = document.createElement('div');
    e.className = 'btn';
    btn = document.createElement('span');
    this.delete_button = e;
    btn.appendChild(document.createTextNode('Delete'));
    (function(o, r) { e.onclick = function() { o.list.delete(r); }})(this, this.ref);
    e.appendChild(btn);
    frame.appendChild(e);
    if (0 == this.ref || !this.edit) {
        e.style.visibility = 'hidden';
    }
    this.fetch();
}
