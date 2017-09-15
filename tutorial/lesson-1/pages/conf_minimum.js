wab.pathPrefix = '/v1/'

entry_list = {
    elements: {
        null: {
            display_class: wab.List,
            config: {
                path: 'Article',
                fields: [ 'title' ]
            },
            actions: {
                view_button: {
                    display: entry_view,
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
    elements: {
        null: {
            display_class: wab.View,
            config: {
                fields: [
                    {
                        path: 'title',
                        type: 'text'
                    },
                    {
                        path: 'text',
                        type: 'textarea'
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
    elements: {
        null: {
            display_class: wab.Edit,
            config: {
                fields: [
                    {
                        path: 'title',
                        type: 'text'
                    },
                    {
                        path: 'text',
                        type: 'textarea'
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
