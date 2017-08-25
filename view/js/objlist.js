
wab.ObjList.prototype.delete = function(ref) {
    httpDelete('/v1/' + this.kind + '/' + ref, this, function(ol, resp) {
        wab.view.set(ol);
    })
}

wab.ObjList.prototype.display = function(view, edit) {
    var wrapper = classifyNewElement('div', 'table-wrapper');
    view.appendChild(wrapper);

    e = classifyNewElement('div', 'btn');

    btn = document.createElement('span');
    btn.appendChild(document.createTextNode('Create'));

    (function(ol) { e.onclick = function() { wab.view.set(new wab.Obj(0, ol), true); }})(this);
    e.appendChild(btn);
    wrapper.appendChild(e);

    var frame = document.createElement('table'), list, row, cell;
    wrapper.appendChild(frame);

    row = document.createElement('tr');
    frame.appendChild(row);

    header = classifyNewElement('table', 'obj-list-table');
    row.appendChild(header);

    row = document.createElement('tr');
    header.appendChild(row);

    var cs, len = this.spec.list.length, opt = '/list?'
    for (i = 0; i < len; i++) {
        cs = this.spec.list[i];
        if (0 < i) {
            opt += '&'
        }
        opt += cs.key + '=' + cs.path;
        cell = document.createElement('th');
        cell.appendChild(document.createTextNode(cs.label));
        row.appendChild(cell);
    }
    cell = classifyNewElement('th', 'list-actions');
    cell.appendChild(document.createTextNode('Actions'));
    cell.setAttribute('colspan', 3);
    row.appendChild(cell);

    // Prepare list table.
    row = classifyNewElement('tr', 'list-items');
    frame.appendChild(row);
    list = classifyNewElement('table', 'obj-list-table');
    row.appendChild(list);

    this.list = list;
    
    // Request content.
    httpGet('/v1/' + this.kind + opt, this, function(ol, resp) {
        var results = resp.body.results, btn, bi;
        if (typeof results === 'object') {
            var i, cs, len = ol.spec.list.length;
            var j, obj, rlen = results.length, ref;
            for (j = 0; j < rlen; j++) {
                obj = results[j];
                ref = obj.ref;
                row = document.createElement('tr');
                ol.list.appendChild(row);
                for (i = 0; i < len; i++) {
                    cs = ol.spec.list[i];
                    cell = classifyNewElement('td', 'obj-list');
                    cell.appendChild(document.createTextNode(obj[cs.key]));
                    row.appendChild(cell);
                }
                for (i = 0; i < wab.list_buttons.length; i++) {
                    bi = wab.list_buttons[i];
                    cell = classifyNewElement('td', bi.cn);
                    btn = classifyNewElement('span', bi.icon);
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

