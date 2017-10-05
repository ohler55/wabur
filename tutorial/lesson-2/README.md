
# WABuR Tutorial Lesson 2

In this short lesson CSS changes are covered.

## Sass

The WABuR project uses [Sass](http://sass-lang.com) to generate CSS for the
reference implementation UI. Files are located in the project `view/ui/styles`
directory. The command to generate the `wab.css` file assuming the command is
run from the wabur repo root is:

```
$ sass --style compressed view/ui/styles/wab.scss ~/my-blog/site/assets/css
```

## CSS Capture

If you would rather edit the CSS directly then start up and download the
generates `wab.css` and reformat it so it is easier to modify. The URL is
`http://localhost:6363/assets/css/wab.css`. Save this to a file in the blog
directory as `site/assets/css/wab.css`. That file will now be used as the
stylesheet for the UI after a restart.

To reformat the CSS here are a series of replacements that work well. Note
that the `\n` sequence is meant not as two characters but a single newline
character.

 - `;` with `;\n  ` 
 - `*/` with `*/\n`
 - `}` with `;\n}\n`
 - `{` with `{\n  `
 
The result should look similar to the file in
[blog/site/assets/css/wab.css](blog/site/assets/css/wab.css).

The CSS file is now ready for a few changes. Modify it as desired. For this
lesson just the colors of the page header and the buttons will be
changed. Three style classes will be changed.

Looking at the `index.html` file created in the earlier lesson note the
`header` class. Changing the background to `#800` will give us a dark red
header. Next the list header which used the `obj-list-table` style
class. Change that background as well. The blue buttons look out of place so
lets change those to a dark yellow. The style class for the buttons is
`btn`. Change the color to `#222` and the background to `#db0`. Not that a
page refresh will show the style changes. The server does not need to be
restarted.
