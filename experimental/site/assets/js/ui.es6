
import * as wab from './wab.es6';

function displayError(msg) {
    // TBD handle this better than an alert. Create an error display and call master.setFlow
    alert(msg);
}

function objGet(obj, path, index) {
    if (path.length - 1 == index) {
        return obj[path[index]];
    }
    if (index < path.length - 1) {
        let node = obj[path[index]];

        if (null != node) {
            return objGet(node, path, index + 1);
        }
    }
    return null;
}

function objSet(obj, path, index, value) {
    if (path.length - 1 == index) {
        obj[path[index]] = value;
    } else if (index < path.length - 1) {
        let node = obj[path[index]];

        if (null == node) {
            node = {};
        }
        objSet(node, path, index + 1, value);
    }
}

// This fuunction is not intended for public use.
function buildDisplay(spec) {
    switch (spec.display_class) {
        case 'ui.List':
            return new List(spec);
        case 'ui.Create':
            return new Create(spec);
        case 'ui.View':
            return new View(spec);
        case 'ui.Update':
            return new Update(spec);
        default:
            displayError(`${spec.display_class} is not a known display class.`);
    }
    return null;
}

export class Master {
    constructor() {
        this.view = document.getElementById("view");
        this.flow = {};

        // If no response or error response expect the setFlow() method will
        // be called later.
        wab.list('ui', null).then(flow => {
            this.setFlow(flow);
        }).catch(function (response) {});
    }

    setFlow(spec) {
        if (0 != spec.code) {
            displayError(spec.error);
            return;
        }
        let entry = null;
        for (let display of spec.results) {
            this.flow[display.name] = buildDisplay(display);
            if (display.entry) {
                entry = display.name;
            }
        }
        if (null != entry) {
            this.setDisplay(entry, null);
        }
    }

    setDisplay(displayId, ref) {
        let child;

        // Clear out any existing elements in the view.
        while (null != (child = this.view.firstChild)) {
            this.view.removeChild(child);
        }
        let display = this.flow[displayId];
        if (null == display) {
            displayError(`Display ${displayId} not found.`);
            return;
        }
        display.display(this.view, ref);
    }
}

export class Display {
    constructor(spec) {
        this.spec = spec;
    }

    _transition(target, ref) {
        if (null != target) {
            master.setDisplay(target, ref);
        }
    }

    _del(target, ref) {
        wab.del(this.spec.kind, ref).then(response => {
            if (null != target) {
                master.setDisplay(target, ref);
            }
        }).catch(function (response) {
            displayError(response);
        });
    }

    display(view, ref) {}
}

export class List extends Display {
    constructor(spec) {
        super(spec);
        this.table = null;
    }

    _appendObjects(response) {
        if (0 != response.code) {
            displayError(response.error);
            return;
        }
        for (let obj of response.results) {
            let tr = document.createElement('tr');
            tr.innerHTML = this.spec.row;
            this.table.appendChild(tr);
            for (let child of tr.childNodes) {
                let path = child.getAttribute('path');
                if (null != path) {
                    child.appendChild(document.createTextNode(String(objGet(obj.data, path.split('.'), 0))));
                }
            }
            for (let child of tr.getElementsByTagName('*')) {
                switch (child.getAttribute('title')) {
                    case 'View':
                        child.onclick = event => {
                            this._transition(this.spec.transitions.view, obj.id);
                        };
                        break;
                    case 'Edit':
                        child.onclick = event => {
                            this._transition(this.spec.transitions.edit, obj.id);
                        };
                        break;
                    case 'Delete':
                        child.onclick = event => {
                            this._del(this.spec.transitions['delete'], obj.id);
                        };
                        break;
                    default:
                        break;
                }
            }
        }
    }

    display(view, ref) {
        view.innerHTML = this.spec.table;
        this.table = document.getElementById(`${this.spec.name}.table`);

        let button = document.getElementById(`${this.spec.name}.create_button`);

        if (null != button) {
            button.onclick = event => {
                this._transition(this.spec.transitions.create, null);
            };
        }
        wab.list(this.spec.kind, null).then(response => {
            this._appendObjects(response);
        }).catch(function (response) {
            displayError(response);
        });
    }
}

export class ObjectDisplay extends Display {
    constructor(spec) {
        super(spec);
        this.ref = 0;
    }

    _setFields(path, obj) {
        let element;
        let value;

        for (let key in obj) {
            if (obj.hasOwnProperty(key) && null != (element = document.getElementById(`${path}.${key}`))) {
                value = obj[key];
                if (value instanceof Object) {
                    this._setFields(`${path}.${key}`, value);
                } else {
                    element.value = obj[key];
                }
            }
        }
    }

    _populate(ref) {
        wab.get(this.spec.kind, ref).then(response => {
            if (0 != response.code) {
                throw response.error;
            }
            let obj = response.results[0];

            if (null != obj) {
                this.ref = obj.id;
                this._setFields(this.spec.name, obj.data);
            }
        }).catch(function (response) {
            displayError(response);
        });
    }

    display(view, ref) {
        view.innerHTML = this.spec.html;
        this._setupButtons();
        this._populate(ref);
    }
}

export class View extends ObjectDisplay {
    constructor(spec) {
        super(spec);
    }

    _setupButtons() {
        let button;

        if (null != (button = document.getElementById(`${this.spec.name}.list_button`))) {
            button.onclick = event => {
                this._transition(this.spec.transitions.list, null);
            };
        }
        if (null != (button = document.getElementById(`${this.spec.name}.edit_button`))) {
            button.onclick = event => {
                this._transition(this.spec.transitions.edit, this.ref);
            };
        }
        if (null != (button = document.getElementById(`${this.spec.name}.delete_button`))) {
            button.onclick = event => {
                this._del(this.spec.transitions['delete'], this.ref);
            };
        }
    }
}

function addToObject(obj, input) {
    let value;

    if ('checkbox' == input.type) {
        value = input.checked;
    } else if ('number' == input.type || 'range' == input.type) {
        value = parseFloat(input.value);
    } else {
        value = input.value;
    }
    // the id is if the form Entry.edit.field
    objSet(obj, input.id.split('.'), 2, value);
}

export class Create extends ObjectDisplay {
    constructor(spec) {
        super(spec);
    }

    _save(target) {
        let obj = { kind: this.spec.kind };

        for (let input of document.getElementsByTagName('INPUT')) {
            addToObject(obj, input);
        }
        for (let input of document.getElementsByTagName('TEXTAREA')) {
            addToObject(obj, input);
        }

        wab.create(this.spec.kind, obj, null).then(response => {
            if (0 != response.code) {
                throw response.error;
            }
            this.ref = response.ref;
            if (null != target) {
                master.setDisplay(target, this.ref);
            }
        }).catch(function (response) {
            displayError(response);
        });
    }

    _setupButtons() {
        let button;

        if (null != (button = document.getElementById(`${this.spec.name}.save_button`))) {
            button.onclick = event => {
                this._save(this.spec.transitions.save);
            };
        }
        if (null != (button = document.getElementById(`${this.spec.name}.cancel_button`))) {
            button.onclick = event => {
                this._transition(this.spec.transitions.cancel, null);
            };
        }
    }
    _populate(ref) {}
}

export class Update extends ObjectDisplay {
    constructor(spec) {
        super(spec);
    }

    _save(target) {
        let obj = { kind: this.spec.kind };

        for (let input of document.getElementsByTagName('INPUT')) {
            addToObject(obj, input);
        }
        for (let input of document.getElementsByTagName('TEXTAREA')) {
            addToObject(obj, input);
        }

        wab.update(this.spec.kind, this.ref, obj, null).then(response => {
            if (0 != response.code) {
                throw response.error;
            }
            this.ref = response.updated[0];
            if (null != target) {
                master.setDisplay(target, this.ref);
            }
        }).catch(function (response) {
            displayError(response);
        });
    }

    _setupButtons() {
        let button;

        if (null != (button = document.getElementById(`${this.spec.name}.save_button`))) {
            button.onclick = event => {
                this._save(this.spec.transitions.save, this.ref);
            };
        }
        if (null != (button = document.getElementById(`${this.spec.name}.cancel_button`))) {
            button.onclick = event => {
                this._transition(this.spec.transitions.cancel, this.ref);
            };
        }
        if (null != (button = document.getElementById(`${this.spec.name}.list_button`))) {
            button.onclick = event => {
                this._transition(this.spec.transitions.list, null);
            };
        }
        if (null != (button = document.getElementById(`${this.spec.name}.delete_button`))) {
            button.onclick = event => {
                this._del(this.spec.transitions['delete'], this.ref);
            };
        }
    }
}

export const master = new Master();
