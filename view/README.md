# View

The view directory consists of sources in sub-directories such as `view/js`, a
sub-directory suitable for serving with an HTTP server named `view/pages`, and
a script that builds some of the pages content from source.

The `build_pages` script pulls all the Javascript files from the `view/js`
directory, compresses them by removing whitespace, and concatenates them
together to for a single wab.js file at `view/pages/assets/js/wab.js`.
