
wab.Obj.prototype.fetch = function() {
    if (0 != this.ref) {
        wab.httpCall('GET', '/v1/' + this.spec.obj.kind + '/' + this.ref, this, function(o, resp) {
            if (0 != resp.code) {
                alert(results.error);
                return;
            }
            var results = resp.results;
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
                    // TBD handle nested, radio, and checkbox
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
}

wab.Obj.prototype.save = function() {
    var obj = { kind: this.spec.obj.kind }, i, row, cell, input;

    for (i = this.form.children.length - 1; 0 <= i; i--) {
        row = this.form.children[i];
        for (j = row.children.length - 1; 0 <= j; j--) {
            cell = row.children[j];
            input = cell.firstChild;
            if ('INPUT' == input.nodeName || 'TEXTAREA' == input.nodeName) {
                if ('checkbox' == input.type) { 
                    obj[input.path] = input.checked;
                } else if ('number' == input.type || 'range' == input.type) {
                    obj[input.path] = parseFloat(input.value);
                } else {
                    obj[input.path] = input.value;
                }
            }
            // TBD handle nested and radio
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
                        o.ref = h.response.ref
                        o.delete_button.style.visibility = 'visible';
                        o.save_button.removeChild(o.save_button.firstChild);
                        o.save_button.appendChild(document.createTextNode('Update'));
                    } else { // update
                        var updated = h.response.updated;
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

wab.Obj.prototype.createInputField = function(spec) {
    var input;
    if ('textarea' == spec.type) {
        input = wab.classifyNewElement('textarea', 'form-field');
    } else if ('radio' == spec.type) {
        // TBD
    } else if (typeof spec.init === 'object') {
        // TBD handle nested values
    } else {
        input = wab.classifyNewElement('input', 'form-field');
        input.type = spec.type;
        var opt, val, i;
        for (i = wab.inputOptions.length - 1; 0 <= i; i--) {
            opt = wab.inputOptions[i];
            if (undefined != (val = spec[opt]) && null != val) {
                input[opt] = val;
            }
        }
    }
    if ('checkbox' == spec.type) {
        input.checked = spec.init;
    } else {
        input.value = spec.init;
    }
    return input;
}

wab.Obj.prototype.display = function(view, edit) {
    this.edit = edit;
    var frame = wab.classifyNewElement('div', 'obj-form-frame'), form, input, row, cell;
    view.appendChild(frame);

    // Lock icon set according to edit flag, add click to flip from edit to view.
    var e = wab.classifyNewElement('div', 'btn lock-btn'), btn = document.createElement('span');
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
    form = wab.classifyNewElement('table', 'obj-form');
    this.form = form;
    frame.appendChild(form);

    // Layout the attribute fields first then request the data or populate with defaults.
    var fields = this.spec.obj.fields, i, f, flen = fields.length;

    for (i = 0; i < flen; i++) {
        f = fields[i];
        row = document.createElement('tr');
        form.appendChild(row);
        cell = wab.classifyNewElement('td', 'field-label');
        cell.appendChild(document.createTextNode(f.label));
        row.appendChild(cell);
        cell = document.createElement('td');
        input = this.createInputField(f);
        if (!edit) {
            input.readOnly = true;
        }
        input.path = f.path;
        cell.appendChild(input);
        row.appendChild(cell);
    }
    e = wab.classifyNewElement('div', 'btn');
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

    e = wab.classifyNewElement('div', 'btn delete-btn');
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
