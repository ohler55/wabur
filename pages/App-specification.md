## Single-page App Specification


```sh
./app-name
├───assets                      # Front-end directory linked from within *./index.html*
|   ├─── css
|   |    └─── wab.css           # App stylesheet
|   ├─── fonts
|   |    └─── wabfont
|   └─── js
|        ├─── js-next
|        |    ├─── foo.js       # ES6 Module component
|        |    ├─── bar.js       # ES6 Module component
|        |    └─── wab.js       # Base ES6 Module that *imports* every other module components
|        └─── wab.js            # ES5 Javascript for old browsers
├─── configs                    # Place for all App config files, including JSON and YAML files
|    └─── wab.conf
├─── controllers                # Place for all controllers in App.
|    ├─── sample_controller.rb
|    └─── foo_controller.rb
└─── index.html                 # The base HTML file accessed at server root.
```

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>App Title</title>
    <link rel="stylesheet" href="assets/css/wab.css" />
  </head>
  <body>
    <script type="module" src="assets/js/js-next/wab.js"></script>
    <script nomodule src="assets/js/wab.js"></script>
  </body>
</html>
```
