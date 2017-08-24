# WABuR (Web Application Builder using Ruby)

[![Build Status](https://img.shields.io/travis/ohler55/wabur/develop.svg)](http://travis-ci.org/ohler55/wabur?branch=develop)
[![Windows Build status](https://img.shields.io/appveyor/ci/ohler55/wabur/develop.svg?label=Windows%20build)](https://ci.appveyor.com/project/ohler55/wabur/branch/develop)
[![Gem Version](https://badge.fury.io/rb/wabur.svg)](https://rubygems.org/gems/wabur)
[![Gem](https://img.shields.io/gem/dt/wabur.svg)](https://rubygems.org/gems/wabur)
[![Coverage Status](https://coveralls.io/repos/github/ohler55/wabur/badge.svg?branch=develop)](https://coveralls.io/github/ohler55/wabur?branch=develop)

Ruby is a great language but for performance C is the better alternative. It is
possible to get the best of both as evident with [Oj](http://www.ohler.com/oj)
and [Ox](http://www.ohler.com/ox). C by itself allowed
[Piper](http://piperpushcache.com), a fast push web server to be developed, and
is being used to develop [OpO](http://opo.technology) a high performance graph
and JSON database. This project takes from all of those projects for a high
performance Ruby web framework.

Ruby on Rails has made Ruby mainstream. While RoR is fine for some
applications there are others that might be better served with an alternative.
This project was started as an alternative to Ruby on Rails with a focus on
performance and ease of use. The use of Javascript for views and NoSQL JSON
databases are some of the most notable differences.

Why develop an alternative to Rails? Developers that want to make more custom
web sites with heavier use of Javascript, Websockets, and SSE along with a
JSON database don't fit nicely in the Rails mold. WAB attempts to address that
area that falls outside of Rail's strengths.

## Goals

Lets start with the primary assumption, that we want to continue using
Ruby. The goal of this project is to provide a high performance, easy to use,
and a fully featured web framework with Ruby at the core. By keeping the core,
the business logic, in Ruby but allowing options for other parts to be in
different languages, the best of each language can be utilized.

Targets are a throughput of 100K page fetches per second at a latency of no
more than 1 millisecond on a desktop machine. That is more than an order of
magnitude faster than Rails and on par with other top of the performance tier
web frameworks across all languages.

[Continue reading ...](pages/Goals.md)

## Architecture

The architecture provides many options but keeps a clean and clear API between
modules. This pluggable design allows for unit test drivers and various levels
of deployment options from straight Ruby to a high performance C runner that
handles HTTP and data storage.

Three configuration are planned. One is to use a Runner that calls to the Ruby
core controller through pipes on ```$stdin``` and ```$stdout```. A second is to implement
a runner in Ruby. The third is to use a C Runner with embedded Ruby.

A Runner that spawns (forks) and runs a Ruby Controller makes use of the
```::WAB::IO::Shell```.

![](http://www.opo.technology/wab/wab_remote_arch.svg)

The Ruby Runner and C Runner with embedded ruby follow the same architecture.

![](http://www.opo.technology/wab/wab_embedded_arch.svg)

Access to data can follow two paths. A direct access to the data is possible
as portrayed by the red line that flows from HTTP server to the runner and
onto the Model. The other path is to dive down into the Ruby Controller and
allow the Controller to modify and control what is returned by a request. The
Benchmark results in the example/sample/README.md includes the latest results.

![](http://www.opo.technology/wab/wab_access_paths.svg)

[Continue reading ...](pages/Architecture.md)

## Try It!

A sample is now available in the ```examples/sample/``` directory. There are
some preliminary laptop benchmark results described in the README.

## Participate and Contribute

If you like the idea and want to help out, or become a core developer on the
project, send me an [email](mailto:peter@ohler.com). Get in on the ground floor
and lets make something awesome together.

### Guidelines

These are the simple guidelines for contributing.

1. Coordinate with me first before getting started to avoid duplication of
   effort or implementing something in conflict with the plans.

2. Branch off the develop branch and submit a PR.

3. Write unit tests.

4. Write straight forward, clean, and simple code. No magic stuff, no monkey
   patching Ruby core classes, and no inheriting from core classes.

## Planning

The plan is informal and high level until more details are defined.

[Details ...](pages/Plan.md)
