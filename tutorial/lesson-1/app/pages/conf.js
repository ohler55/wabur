wab.pathPrefix = '/v1/'

entry_list = {
    elements: {
        one: {
            display_class: wab.List,
            config: {
                kind: 'Article',
                fields: [ 'title' ]
            },
            actions: {
                create_button: entry_create,
                view_button: entry_view,
                edit_button: entry_view,
                delete_button: entry_list
            }
        }
    }
}

entry_create = {
    elements: {
        one: {
            display_class: wab.Create,
            config: {
                fields: [ 'title', 'content' ]
            },
            actions: {
                save_button: entry_view,
                cancel_button: entry_list
            }
        }
    }
}

entry_view = {
    elements: {
        one: {
            display_class: wab.View,
            config: {
                fields: [ 'title', 'content' ]
            },
            actions: {
                lock_button: entry_edit
            }
        }
    }
}

entry_edit = {
    elements: {
        one: {
            display_class: wab.Edit,
            config: {
                fields: [ 'title', 'content' ]
            },
            actions: {
                lock_button: entry_view,
                save_button: entry_view,
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
        },
        entry_create: {
            display: entry_create
        },
        entry_view: {
            display: entry_view
        },
        entry_edit: {
            display: entry_edit
        }
    }    
}

wab.set_flow(flow);
