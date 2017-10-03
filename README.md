# WABuR (Web Application Builder using Ruby)

[![Build Status](https://img.shields.io/travis/ohler55/wabur/develop.svg)](http://travis-ci.org/ohler55/wabur?branch=develop)
[![Windows Build status](https://img.shields.io/appveyor/ci/ohler55/wabur/develop.svg?label=Windows%20build)](https://ci.appveyor.com/project/ohler55/wabur/branch/develop)
[![Gem Version](https://badge.fury.io/rb/wabur.svg)](https://rubygems.org/gems/wabur)
[![Gem](https://img.shields.io/gem/dt/wabur.svg)](https://rubygems.org/gems/wabur)

WABuR is a Web Application Builder using Ruby. It employs a modern NoSQL JSON
data store and a single-page UI using JavaScript. The best part is that it is
simple and very fast, hitting over 200,000 fetches a second with a Ruby core!

It is pluggable and extendable in many ways to allow new additions,
alternative databases, and any number of UIs.

A natural question is *"What about Rails?"*. Rails is well established and has
a huge user base. WABuR is not a replacement for Rails. It is an alternative
for those who want to explore using JSON databases with a single-page dynamic
JavaScript UI.

For further reading there is an [architecture page](pages/Architecture.md)

## Try It!

Want to know more? A tutorial is available in the [tutorial](tutorial/README.md)
directory.

More interested in the benchmarks? Then take a look at the [benchmarks page](benchmarks/README.md).

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
