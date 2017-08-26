
wab.List.prototype.delete = function(ref) {
    wab.httpCall('DELETE', '/v1/' + this.kind + '/' + ref, this, function(ol, resp) {
        wab.view.set(ol);
    })
}

wab.List.prototype.display = function(view, edit) {
    var wrapper = wab.classifyNewElement('div', 'table-wrapper');
    view.appendChild(wrapper);

    e = wab.classifyNewElement('div', 'btn');

    btn = document.createElement('span');
    btn.appendChild(document.createTextNode('Create'));

    (function(ol) { e.onclick = function() { wab.view.set(new wab.Obj(0, ol), true); }})(this);
    e.appendChild(btn);
    wrapper.appendChild(e);

    var frame = document.createElement('table'), table, row, cell;
    wrapper.appendChild(frame);

    row = document.createElement('tr');
    frame.appendChild(row);

    header = wab.classifyNewElement('table', 'obj-list-table');
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
    cell = wab.classifyNewElement('th', 'list-actions');
    cell.appendChild(document.createTextNode('Actions'));
    cell.setAttribute('colspan', 3);
    row.appendChild(cell);

    // Prepare list table.
    row = wab.classifyNewElement('tr', 'list-items');
    frame.appendChild(row);
    table = wab.classifyNewElement('table', 'obj-list-table');
    row.appendChild(table);

    this.table = table;
    
    // Request content.
    wab.httpCall('GET', '/v1/' + this.kind + opt, this, function(list, resp) {
        var results = resp.body.results, btn, bi;
        if (typeof results === 'object') {
            var i, cs, len = list.spec.list.length;
            var j, obj, rlen = results.length, ref;
            for (j = 0; j < rlen; j++) {
                obj = results[j];
                ref = obj.ref;
                row = document.createElement('tr');
                list.table.appendChild(row);
                for (i = 0; i < len; i++) {
                    cs = list.spec.list[i];
                    cell = wab.classifyNewElement('td', 'obj-list');
                    cell.appendChild(document.createTextNode(obj[cs.key]));
                    row.appendChild(cell);
                }
                for (i = 0; i < wab.listButtons.length; i++) {
                    bi = wab.listButtons[i];
                    cell = wab.classifyNewElement('td', bi.cn);
                    btn = wab.classifyNewElement('span', bi.icon);
                    btn.setAttribute('title', bi.title);
                    cell.appendChild(btn);
                    // A function is needed to copy the variables.
                    (function(list, r, b, act) {
                        switch(act) {
                        case 2:
                            b.onclick = function() { list.delete(r); }
                            break;
                        case 1:
                            b.onclick = function() { wab.view.set(new wab.Obj(r, list), true); }
                            break;
                        case 0:
                        default:
                            b.onclick = function() { wab.view.set(new wab.Obj(r, list), false); }
                        }
                    })(list, ref, btn, bi.act);
                    row.appendChild(cell);
                }
            }
        }
    })
}

