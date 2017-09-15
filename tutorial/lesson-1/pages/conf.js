// This file must be loaded after the wab.js file. It is the configuration for
// a WAB web site and uses the WAB reference implementation.

// Identify the URL path prefix for requests to the WAB backend. Since the
// reference implementation follows a REST model a URL that gets an Entry JSON
// record with a reference identifier of 11 would look like
// `http://localhost:6363/v1/Entry/11.
wab.pathPrefix = '/v1/'

// The view specification is composed of individual display specification as
// well as a flow that ties all the separate displays together. The tying
// together of the separate displays is similar to a process flow
// diagram. Individual displays are analogous tasks in a process flow and the
// process flow transitions are the same as actions taken on events that cause
// the displays to transition from one to another.

// The UI flow is specifiec by a single JSON Object where each key of the
// object identifies display and the displays are described by another JSON
// Object. To better organize this structure the display specification are
// described first and then a flow ties the displays together.

// All displays are enclosed in a frame which is described by an HTML page.

// First the the frame and individual displays are defined. Each of the
// displays will become an element in the HTML element with an id of 'view'.

// Although not used in the first lesson, additional frame elements such as a
// class list can be specified as elements of the frame. Each element in the
// frame has a key corresponding to the id of an HTML element in the
// index.html file. The description after the key is the same as the
// specification for individual display elements.
frame = {
    // Nothing here for now.
}

entry_list = {
    layout: null, // There will be only one element so the default layout
                  // manager is fine.
    elements: {
        // Multiple elements can be provided with keys corresponding to the
        // elements expected for the layout manager specified.
        null: {
            display_class: wab.List,
            // Configuration parameters for the display_class.
            config: {
                path: 'Article', // Kind of record to return, a query could be
                                 // used instead.
                fields: [
                    {
                        label: 'Title',
                        path: 'title',
                        width: '200px'
                    }
                ]
            },
            // The actions to take for supported events on th
            // edisplay_class. In the case of the wab.List, three buttons
            // events are supported. The actions are hardcoded and the action
            // will take place after the hardcoded action. If the button has
            // no action then it is not displayed. If not null then a
            // description of the display to transition to should be provided
            // or a key in the flow description can be used instead.
            actions: {
                view_button: {
                    display: entry_view,
                    // Arguments are a single quoted string with the the kind
                    // of record followed by the attribute path or key. $ref
                    // is the build in record reference identifier.
                    args: [ "'Article", '$ref' ]
                },
                edit_button: {
                    display: entry_view,
                    args: [ "'Article", '$ref' ]
                },
                delete_button: {
                    display: entry_list,
                    args: [ "'Article" ]
                }
            }
        }
    }
}

entry_view = {
    layout: null,
    elements: {
        null: {
            display_class: wab.View,
            // The wab.View will be opened
            config: {
                fields: [
                    {
                        label: 'Title',
                        path: 'title',
                        type: 'text',
                        init: '',
                        width: '200px'
                    },
                    {
                        label: 'Text',
                        path: 'text',
                        type: 'textarea',
                        init: '',
                        width: '80%',
                        rows: 4
                    }
                ]
            },
            actions: {
                lock_button: entry_edit
            }
        }
    }
    
}

entry_edit = {
    layout: null,
    elements: {
        null: {
            display_class: wab.Edit,
            config: {
                fields: [
                    {
                        label: 'Title',
                        path: 'title',
                        type: 'text',
                        init: '',
                        width: '200px'
                    },
                    {
                        label: 'Text',
                        path: 'text',
                        type: 'textarea',
                        init: '',
                        width: '80%',
                        rows: 4
                    }
                ]
            },
            actions: {
                lock_button: entry_view,
                save_button: entry_edit,
                delete_button: entry_list
            }
        }
    }
}

flow = {
    initial: 'entry_list',
    displays: {
        entry_list: {
            display: entry_list,
            // Optional for display in the UI flow editor.
            geometry: { x: 10, y: 10, w: 100, h: 80 },
            // Path specification for transition drawing in the UI flow
            // editor. Each array element is an array fo x and y coordinates.
            transitions: {
                view_button: [ [ 200, 50 ] ],
                edit_button: [ [ 60, 150 ] ]
            }
        },
        // The minimum required to run. No UI flow editor information.
        entry_view: {
            display: entry_view
        },
        entry_edit: {
            display: entry_edit
        }
    }    
}

// Tell the wab view module what flow to use.
wab.set_flow(flow);
