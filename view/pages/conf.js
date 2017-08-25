// This file is loaded after the wab.js file. The wab.view should be
// configured first then a call to wab.view.set() is made to draws the initial
// display.

// Example of registering a class by name and template/specificaiton.
wab.view.register_type('Article',
                       {
                           list: [
                               {
                                   label: 'Title',
                                   path: 'title',
                                   key: 'name',
                                   width: '200px'
                               },
                               {
                                   label: 'Text',
                                   path: 'text',
                                   key: 'body',
                                   width: 'auto'
                               }
                           ],
                           obj: {
                               kind: 'Article',
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
                           }
                       });

wab.view.register_type('Other',
                       {
                           list: [
                               {
                                   label: 'Name',
                                   path: 'name',
                                   key: 'name'
                               }
                           ],
                           obj: {
                               kind: 'Other',
                               fields: [
                                   {
                                       label: 'Name',
                                       path: 'name',
                                       type: 'text',
                                       init: '',
                                       required: true,
                                       maxlength: 8
                                   },
                                   {
                                       label: 'Scale',
                                       path: 'scale',
                                       type: 'range',
                                       init: '50',
                                       min: 5,
                                       max: 100,
                                       step: 5
                                   },
                                   {
                                       label: 'Age',
                                       path: 'age',
                                       type: 'number',
                                       step: 'any',
                                       init: '1'
                                   },
                                   {
                                       label: 'Good',
                                       path: 'good',
                                       type: 'checkbox',
                                       init: true
                                   },
                                   {
                                       label: 'When',
                                       path: 'when',
                                       type: 'datetime-local',
                                       init: ''
                                   },
                                   {
                                       label: 'Password',
                                       path: 'password',
                                       type: 'password',
                                       init: ''
                                   }
                               ]
                           }
                       });

wab.view.set(null);
