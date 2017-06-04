# Goals

The goal is to provide a high performance, easy to use, and fully featured web
framework that uses Ruby for business logic. Following a Model/View/Controller
model Ruby is used to implement the Controller portion. Using the best
language for each portion of the MVC the View is implemented in JavaScript,
HTML, and CSS. The Model is simply a NoSQL data store.

To address the ease of use clean and clear APIs are used between each part of
the MVC and JSON is the data representation throughout. Ruby is straight Ruby
with no monkey patched core classes and no magic. Plain and simple Ruby.

## Performance

With a goal of building a high performance system the architecture is design
from the start to deliver the best performance possible. Code will also
developed with that goal in mind. All code will be unit tested and benchmarks
made where applicable.

### Approach

The architecture is module and follows a Model View Controller design pattern
with clear and defined APIs between each module. This will ensure a clear
division between the Model, View, and Controller modules.

With a modular design the most appropriate data store can be selected. By
being able to swap out different storage modules choices can be made between
hooking up to an existing SQL or NoSQL data store or using a faster or more
scaleable choice.

A separation of data and behavior is part of the overall approach. By keeping
the data separate and devoid of behavior the movement of data between the
elements of the MVC doesn't drag along methods not appropriate for the
component. It also allows behavior to be implemented without impacting the
data and updated and modified without a global replacement of the system as a
whole. Related to this approach is that there will be absolutely no monkey
patching of core Ruby classes. Monkey patching creates unexpected behavior and
cause conflicts between modules.

Serialization must be fast and reduced to a minimum. The APIs provide an
abstraction that allows optimized data structures to be used as long as they
follow a JSON model view through the access APIs.

Ruby code is kept as simple and direct as possible to reduce the overhead of
deeply nested calls and object creation.

There are parts of the system that can be written in higher performance
languages such as C. This includes the HTTP and data stores. By allowing use
of a mixed environment the best performance can be achieved.

### Targets

Targets are a throughput of 100K page fetches per second at a latency of no
more than 1 millisecond on a desktop machine. That is more than an order of
magnitude faster than Rails and on par with other top of the performance tier
web frameworks in all languages.

The throughput and latency targets are not unreasonable as
[OpO](http://opo.technology) as an HTTP server providing JSON documents with
the Ruby controller has demonstrated that 140K fetches per second with a
latency of 0.6 milliseconds is possible on a desktop machine. With a thin Ruby
controller or a bypass for simple fetches the additional overhead is minimal.

The system must be scaleable in at least one configuration. Possibly using
multiple Ruby instances as processes or threads.

In the final deployment the aim is for upper part of performance tier when
compared to other web framework across all languages. Right now in
[benchmarks](https://gist.github.com/omnibs/e5e72b31e6bd25caf39a) Rails and
Sinatra occupy the bottom slots. WAB will put Ruby near the top.

## Easy to Use

In addition to performance goals WAB must be easy to use not only for a
'Hello World' application but for advanced systems as well. The learning curve
must be shallow to allow new users to get started immediately and then
progress onto more advanced features.

### Simplicity, Clear, and Simple

The Ruby code used in WAB will be simple and direct. There will be no
magic. Clear documented class definitions with shallow class hierachy
throughout.

### Development

Development is a cycle of edit and test repeated over and over again. The
faster that cycle is the more friendly the development environment. Keep
modules encapsulated with well defined APIs allows this cycle to be fast as
unit tests just test against the APIs.

This strategy of well defined APIs and testing continues at all levels up to
system testing.

### Upgrade Path

It is expected that the development environment will use a Ruby shell while
larger scale production will use a C shell. That doesn't mean moving to a C
WAB shell is necessary but it can be used if needed.

## Best for Purpose

Ruby is appropriate for the business logic expected in the Controller in the
MVC model but there are no advantages to using Ruby to form HTML pages for the
View. JavaScript, HTML, and CSS are a better choice. Along similar lines,
there is no advantage of using Ruby to write the data store or for that matter
using Ruby to convert data into database calls. In the development shell it is
fine but the option to use another language should be available for
performance reasons. That allows the data store to be a service independent of
the Ruby code.
