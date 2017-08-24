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
                                   label: 'One',
                                   path: 'one',
                                   key: 'n1',
                                   width: '100px'
                               },
                               {
                                   label: 'Two',
                                   path: 'two',
                                   key: 'n2',
                                   width: '100px'
                               },
                               {
                                   label: 'Three',
                                   path: 'three',
                                   key: 'n3',
                                   width: '100px'
                               },
                               {
                                   label: 'Four',
                                   path: 'four',
                                   key: 'n4',
                                   width: '100px'
                               },
                               {
                                   label: 'Text',
                                   path: 'text',
                                   key: 'body',
                               }
                           ],
                           obj: {
                               kind: 'Other',
                               fields: [
                                   {
                                       label: 'One',
                                       path: 'one',
                                       type: 'text',
                                       init: '',
                                       width: 0,
                                       height: 1
                                   },
                                   {
                                       label: 'Two',
                                       path: 'two',
                                       type: 'text',
                                       init: '',
                                       width: 0,
                                       height: 1
                                   },
                                   {
                                       label: 'Three',
                                       path: 'three',
                                       type: 'text',
                                       init: '',
                                       width: 0,
                                       height: 1
                                   },
                                   {
                                       label: 'Four',
                                       path: 'four',
                                       type: 'text',
                                       init: '',
                                       width: 0,
                                       height: 1
                                   },
                                   {
                                       label: 'Text',
                                       path: 'text',
                                       type: 'text',
                                       init: '',
                                       width: 0,
                                       height: 4
                                   }
                               ]
                           }
                       });

wab.view.set(null);
