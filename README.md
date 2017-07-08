# WABuR (Web Application Builder using Ruby)

[![Build Status](https://img.shields.io/travis/ohler55/wabur/develop.svg)](http://travis-ci.org/ohler55/wabur?branch=develop) ![Gem](https://img.shields.io/gem/v/wabur.svg) ![Gem](https://img.shields.io/gem/dt/wabur.svg)

Ruby is a great language but for performance C is a better alternative. It is
possible to get the best of both as evident with [Oj](http://www.ohler.com/oj)
and [Ox](http://www.ohler.com/ox). C by itself allowed
[Piper](http://piperpushcache.com), a fast push web server to be developed and
is being used to develop [OpO](http://opo.technology) a high performance graph
and JSON database. This project takes from all of those projects for a hight
performance Ruby web framework.

Ruby on Rails has made Ruby main stream. While RoR is fine for some
applications there are others that might be better served with an alternative.
This project was started as an alternative to Ruby on Rails with a focus on
performance and easy of use.

Why develop an alternative to Rails? Rails popularity has been waning. It is
still huge but not as popular as it used to be. RoR is not going away any time
soon but for some applications alternatives are needed.

## Goals

Lets start with the assumption that we want to continue to use Ruby. The goal
of this project is to provide a high performance, easy to use, and fully
featured web framework with Ruby at the core. By keeping the core, the
business logic in Ruby but allowing options for other parts to be in different
languages the best use of each can be utilized.

Targets are a throughput of 100K page fetches per second at a latency of no
more than 1 millisecond on a desktop machine. That is more than an order of
magnitude faster than Rails and on par with other top of the performance tier
web frameworks across all languages.

[Continue reading ...](pages/Goals.md)

## Architecture

The architecture provides many options but it keeps clean and clear APIs
between modules. This pluggable design allows for unit test drivers and
various levels of deployment options from straight Ruby to a high performance
C shell that handles HTTP and data storage.

![](http://www.opo.technology/wab/wab_arch.svg)

[Continue reading ...](pages/Architecture.md)

## Participate and Contribute

If you like the idea and want to help out or become a core developer on the
project send me an [email](mailto:peter@ohler.com). Get in on the ground floor
and lets make something awesome together.

### Guidelines

These are the simple guidelines for contrinuting.

1. Coordinate with me first before getting started to avoid duplication of
   effort or implementing something in conflict with the plans.

2. Branch off the develop branch and submit a PR.

3. Write unit tests.

4. Write straight forward, clean, and simple code. No magic stuff, no monkey
   patching Ruby core classes, and no inheriting from core classes.

## Planning

The plan is informal and high level until more details are defined.

[Details ...](pages/Plan.md)
