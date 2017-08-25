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
    Obj: function Obj(ref, list) {
        this.ref = ref;
        this.list = list;
        this.spec = list.spec;
        this.form = null;
        this.lock = null;
        this.edit = false;
        this.save_button = null;
        this.delete_button = null;
    },
    // The act attribute is an enum value 0=view, 1=edit, 2=delete
    list_buttons: [
        { title: 'View', icon: 'icon icon-eye', cn: 'actions', act: 0 },
        { title: 'Edit', icon: 'icon icon-pencil', cn: 'actions', act: 1 },
        { title: 'Delete', icon: 'icon icon-trash-o', cn: 'actions delete', act: 2 }
    ]
}

// Helper functions.
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

function classifyNewElement(elem, klass) {
    var e = document.createElement(elem);
    e.className = klass;
    return e;
}
