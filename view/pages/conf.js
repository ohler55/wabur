// This file is loaded after the wab.js file. The wab.view should be
// configured first then a call to wab.view.set() is made to draws the initial
// display.

// Example of registering a class by name and template/specificaiton. 
wab.view.register_type('Article',
                       {
                           list: [
                               [ 'Title', 'title', '200px' ],
                               [ 'Text', 'text', 'auto' ]
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
                               [ 'One', 'one', '100px' ],
                               [ 'Two', 'two', '100px' ],
                               [ 'Three', 'three', '100px' ],
                               [ 'Four', 'four', '100px' ],
                               [ 'Text', 'text' ]
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
