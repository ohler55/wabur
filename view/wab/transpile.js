SystemJS.config({
    map: {
        'plugin-babel': 'assets/js/plugin-babel/plugin-babel.js',
        'systemjs-babel-build': 'assets/js/plugin-babel/systemjs-babel-browser.js'
    },
    transpiler: 'plugin-babel'
});
System.import("assets/js/ui.js");
