
import * as wab from './wab.es6';

function displayError(msg) {
    // TBD handle this better than an alert. Create an error display and call master.setFlow
    alert(msg);
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
        wab.list('ui', null).then((flow) => { this.setFlow(flow); }).catch(function(response) {});
    }

    setFlow(spec) {
        console.log('setFlow Ok - ' + JSON.stringify(spec, null, 2));
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

    display(view, ref) {
        console.log(`*** display ${this.spec.name}`);
    }
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
                    child.appendChild(document.createTextNode(String(obj.data[path])));
                }
                // TBD need to supported nested attributes
            }
            for (let child of tr.getElementsByTagName('*')) {
                switch (child.getAttribute('title')) {
                case 'View':
                    child.onclick = (event) => { this._view(event, this.spec.transitions.view, obj.id); };
                    break;
                case 'Edit':
                    child.onclick = (event) => { this._edit(event, this.spec.transitions.edit, obj.id); };
                    break;
                case 'Delete':
                    child.onclick = (event) => { this._del(event, this.spec.transitions['delete'], obj.id); };
                    break;
                default:
                    break;
                }
            }
        }
    }

    _create(event, target) {
        console.log(`*** create clicked - ${target}`);
        if (null != target) {
            master.setDisplay(target, null);
        }
    }

    _view(event, target, ref) {
        console.log(`*** view clicked - ${ref}`);
        if (null != target) {
            master.setDisplay(target, ref);
        }
    }

    _edit(event, target, ref) {
        console.log(`*** edit clicked - ${ref}`);
        if (null != target) {
            master.setDisplay(target, ref);
        }
    }

    _del(event, target, ref) {
        wab.del(this.spec.kind, ref).then((response) => {
            if (null != target) {
                master.setDisplay(target, ref);
            }
        }).catch(function(response) { displayError(response); });
    }

    display(view, ref) {
        view.innerHTML = this.spec.table;
        this.table = document.getElementById(`${this.spec.name}.table`);

        let button = document.getElementById(`${this.spec.name}.create_button`);

        if (null != button) {
            button.onclick = (event) => { this._create(event, this.spec.transitions.create); };
        }
        wab.list(this.spec.kind, null).then((response) => { this._appendObjects(response); }).catch(function(response) { displayError(response); });
    }
}

export class ObjectDisplay extends Display {
    constructor(spec) {
        super(spec);
    }

    _populate(ref) {
        // TBD
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
        // TBD
    }
}

export class Create extends ObjectDisplay {
    constructor(spec) {
        super(spec);
    }

    _setupButtons() {
        // TBD
    }

    _populate(ref) {}
}

export class Update extends ObjectDisplay {
    constructor(spec) {
        super(spec);
    }

    _setupButtons() {
        // TBD
    }
}

export const master = new Master();
