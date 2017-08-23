
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

