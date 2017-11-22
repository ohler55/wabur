
# Why Not ERB?

If you asked the question, "Why not use ERB?" then you probably have a Ruby on
Rails background. For those of you who do not, ERB is Ruby on Rails
technology.

Rails follows a MVC design pattern but all three of the parts, the model,
view, and controller all reside on the server side in Ruby code. The view code
determines what the view will be like and passes fully formed HTML to a
browser which then renders that code. The browsers is strictly a render
engine. The view code determines how data will be displayed. ERB is used to
take objects or data and more easily form HTML with that data.

WABuR follows a MVC pattern but the view is external to the server and the
Ruby code. This allows for more than one type of view. That is not possible
with Rails. With the view separate from the controller, data is passed from
controller to view by passing only the data as JSON. With this design the data
and view code only intersect at the view such a a browser or another client
such as a command line application.

The WABuR reference UI or view bootstraps by getting display discriptions,
HTML from a UI controller class. That class passes the page descriptions or
templates to a JavaScript UI that is running in a browser. No business level
data is passed at that point. The HTML could just as easily be code in the
JapaScript. Later, when running, the link between data and the HTML is the
element `id`. This is common practice with JavaScript. The JavaScript code
gets an element by `id` then sets the value of that element.

So where could ERB be forced into this design? It could be used instead of
JSON as a transport or it could be passed from the UI controller during
bootstrap and then evaluated in the browser. Neither are practical.

If ERB is used to transfer data from the controller to the view then there can
be only one view type, similar to the Rails design. This would prohibit the
use of alternate views and would severly restrict the use of JavaScript use
for dynamic modern UIs.

Sending ERB instead of HTML during the bootstrap process would mean the ERB
would have to be evaluated by the JavaScript code in the browser when JSON
data arrived. ERB is not used in JavaScript. There is no need for it. It is
easier and more clear to use the JavaScript tools available to update HTML
elements directly. For this reason there is no OSS JavaScript ERB evaluator.

There is always a way to force a technology to be used but in this case it
would mean sacrificing functionality or making the UI much more difficult to
build.
