
# WABuR Tutorial Lesson 2

----------------------------------------------------
just saved notes below, ignore


The `conf.js` file is a JavaScript file but it is only used for declarations
and setting up a configuration that is passed to the wab module using the
`wab.setFlow` function. The file show is a minimal version. More options are
available and will be described in a future lesson.

The view configuration describes individual displays as well as what actions
cause a change in the display. After that it is left up to the wab module to
run the show.

```
entryList = {
    elements: {
        null: {
            display_class: wab.List,
            config: {
                kind: 'Entry',
                fields: [ 'title' ]
            },
            actions: {
                createButton: 'entryCreate',
                viewButton: 'entryView',
                editButton: 'entryView',
                deleteButton: 'entryList'
            }
        }
    }
}

entryCreate = {
    elements: {
        one: {
            display_class: wab.Create,
            config: {
                fields: [ 'title', 'content' ]
            },
            actions: {
                saveButton: 'entryView',
                cancelButton: 'entryList'
            }
        }
    }
}

entryView = {
    elements: {
        one: {
            display_class: wab.View,
            config: {
                fields: [ 'title', 'content' ]
            },
            actions: {
                lockButton: 'entryEdit'
            }
        }
    }
}

entryEdit = {
    elements: {
        one: {
            display_class: wab.Edit,
            config: {
                fields: [ 'title', 'content' ]
            },
            actions: {
                lockButton: 'entryView',
                saveButton: 'entryView',
                deleteButton: 'entryList'
            }
        }
    }
}

flow = {
    initial: 'entryList',
    displays: {
        entryList: {
            display: entryList,
        },
        entryCreate: {
            display: entryCreate
        },
        entryView: {
            display: entryView
        },
        entryEdit: {
            display: entryEdit
        }
    }    
}

wab.setFlow(flow);
```

The view specification is composed of individual display specification as well
as a flow that ties all the separate displays together. The tying together of
the separate displays is similar to a process flow diagram. Individual
displays are analogous tasks in a process flow and the process flow
transitions are the same as actions taken on events that cause the displays to
transition from one to another.

The UI flow is specified by a single JSON Object where each key of the object
identifies display and the displays are described by another JSON Object. To
better organize this structure the display specification are described first
and then a flow ties the displays together.

First the individual displays are defined. Each of the
displays will become an element in the HTML element with an id of `view`.

Looking at a display description such as the `entryCreate` there is an
attribute name `elements` that has one or more attributes that describe the
elements in the display. There is only one in this case with an index of
`one`. When there is only one element and no layout manager defined any name
will do.

Within the `elements` single attribute there are three attributes,
`display_class`, `config`, and `actions`. The `display_class` identifies the
JavaScript object to use for the display. The wab module has several built in
classes for list, create, edit, and view. These objects have defaults for the
expected REST behavior. Each has it's own set of actions that can trigger
transitions. The transitions occur after the object takes the default action.

The actions element describes which transition to take for supported events on
the `display_class`. In the case of the wab.List, three buttons events are
supported. The actions are hardcoded and the action will take place after the
hardcoded action. If the button has no action then it is not displayed. If not
null then a description of the display to transition to should be provided or
a key in the flow description can be used instead.

The `config` element includes configuration information specific to the
display type. For the `wab.Create` display class a list of fields that the
user can enter data into is listed. In the simple cas just the field names are
given and a text field is assumed.

The flow variable defines what displays are available and associates them with
name so that the actions defined early can lookup the correct display if a
string identifier was used. It also specifies the initial display to show the
user.
