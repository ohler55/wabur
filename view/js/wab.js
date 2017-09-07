// The wab namespace and constructor definitions. Everything is in this file
// to minimize page fetchs from the server.

var wab = {
    View: function() {
        this.view = document.getElementById("view");
        this.page = null;
        this.specs = {};
    },
    List: function List(kind, spec) {
        this.kind = kind;
        this.spec = spec;
        this.table = null;
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
    listButtons: [
        { title: 'View', icon: 'icon icon-eye', cn: 'actions', act: 0 },
        { title: 'Edit', icon: 'icon icon-pencil', cn: 'actions', act: 1 },
        { title: 'Delete', icon: 'icon icon-trash-o', cn: 'actions delete', act: 2 }
    ],
    inputOptions: [ 'required', 'maxlength', 'pattern', 'min', 'max', 'step' ],

    // Helper functions.
    httpCall: function(verb, url, obj, callback) {
        if (verb != 'GET' && verb != 'DELETE') return null;

        var h = new XMLHttpRequest();
        h.open(verb, url, true);
        h.responseType = 'json';
        h.onreadystatechange = function() {
            if (4 == h.readyState) {
                if (200 == h.status) {
                    callback(obj, h.response);
                } else {
                    alert(verb + ': ' + url + ' returned ' + h.status + '.');
                }
            }
        };
        h.send();
    },
    classifyNewElement: function(elem, klass) {
        var e = document.createElement(elem);
        e.className = klass;
        return e;
    }
}
