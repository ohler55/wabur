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
                               title: '',
                               text: ''
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
                               title: '',
                               text: ''
                           }
                       });

wab.view.set(null);
