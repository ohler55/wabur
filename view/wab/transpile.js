SystemJS.config({
    map: {
        'plugin-babel': 'assets/js/vendor/plugin-babel/plugin-babel.js',
        'systemjs-babel-build': 'assets/js/vendor/plugin-babel/systemjs-babel-browser.js'
    },
    transpiler: 'plugin-babel'
});
System.import("assets/js/ui.js");
