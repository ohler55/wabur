
# WABuR Tutorial Lesson 1

This first lesson of the WABuR Tutorial covers.

 - [Application Design](#application-design)
 - [WABuR Components and Terminology](#wabur-components-and-terminology)
 - [Development Environment](#development-environment)
 - [File and Directory Organization](#file-and-directory-organization)
 - [Implementation](#implementation)
 - [Running](#running)
 - [Testing](#testing)

## Application Design

## WABuR Components and Terminology



![](wab_parts.svg)


## Development Environment

## File and Directory Organization

## Implementation

- point to files and directory for running

## Running

## Testing




- design and planning
 - object based
 - what should be shown
  - list
  - create
  - view
  - modify
  
- WAB design pattern
 - diagram of parts
 - MVC
  - each part is a separate with APIs between
  - server side
   - runner and shell
   - controller
    - ruby, some options there that are transparent to controller code, don't worry about it
   - model
    - simple files
    - mongo, redis, other
     - first support one is OpO for high performance
  - client (browser) side
   - page == display, use javascript so URL remains the same
    - page to run a Javascript app in
   - loosely typed object model for each display
   - Javascript
    - for display
      - match controller for the API, controller can build from DB or take directly
    - for exchanging data with controller through runner and shell
     - message based interactions

- development
 - runner is pure ruby wabur
 - APIs allow unit tests
 - test driven
  - unit test controller
  - hook runner, use curl for driving without view
  - use browser for view

- where to put files
 - runner configs
 - controller ruby
 - pages
  - conf.js
  - addition js

- design
 - Entry
  - title, content
 - direct storage
- implement
 - controller.rb
 - index.html
 - conf.js
- run
 - config runner
 - try it
- unit tests (should be done earlier but it is a quick start)
 - controller
 - with runner



TBD the lesson steps and explanation

TBD reference to support files and pages
