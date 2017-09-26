
import * as wab from '../../wab/es6/wab.js';

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
            this.setDisplay(entry);
        }
    }

    setDisplay(displayId) {
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
        display.reset();
        display.display(this.view);
    }

}

export class Display {
    constructor(spec) {
        this.spec = spec;
    }

    reset() {
        console.log(`*** reset ${this.spec.name}`);
    }

    display(view) {
        console.log(`*** display ${this.spec.name}`);
    }
}

export class List extends Display {
    constructor(spec) {
        super(spec);
        this.table = null;
    }

    reset() {
        console.log(`*** list reset ${this.spec.name}`);
        // TBD reset or zero out all fields
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
                if (null == path) {
                    continue;
                }
                // TBD need to supported nested attributes
                child.appendChild(document.createTextNode(String(obj.data[path])));
            }
        }
    }

    display(view) {
        view.innerHTML = this.spec.table;
        this.table = document.getElementById(`${this.spec.name}.table`);

        wab.list(this.spec.kind, null).then((response) => { this._appendObjects(response); }).catch(function(response) { displayError(response); });
    }
}

export class View extends Display {
    constructor(spec) {
        super(spec);
    }
}

export class Create extends Display {
    constructor(spec) {
        super(spec);
    }
}

export class Update extends Display {
    constructor(spec) {
        super(spec);
    }
}

export const master = new Master();
