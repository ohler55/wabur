// This file is loaded after the wab.js file. The wab.view should be
// configured first then a call to wab.view.set() is made to draws the initial
// display.

// Example of registering a class by name and template/specificaiton. 
wab.view.register_class('Article', { kind: 'Article', title: '', text: '' });
wab.view.register_class('Other', { kind: 'Other', title: '', text: '' });

wab.view.set(null);
