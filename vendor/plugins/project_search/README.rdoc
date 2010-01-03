ProjectSearch
=============
 
The project searcher is like a Rails-aware grep that can be used to quickly
search specific areas of your project. Even if you're already proficient with
the Unix find and grep commands, this finder tool can save you precious
key-strokes.

Installing the plugin adds a 'find' script under your project's 'script'
directory.

You invoke the command with an optional "scope", and a "term" (a regular
expression pattern) to search for. If the scope is omitted, it defaults to
"all". The supported scopes and their meanings are:

* "all": search app, config, lib, test, and public directories.
* "code": search app (except for app/views), config, lib, and test.
* "css": search just the public/stylesheets directory.
* "js": search just the public/javascripts directory.

You can also specify "helper", "model", "presenter", "service", "view"
"controller", or "concern", which will search in the pluralized version of
that directory under "app".

Any other scope argument is interpreted to mean the directory name itself that
you want to search.

Note that only files with the following extensions are searched:

* rb
* rjs
* rhtml
* rxml
* erb
* builder
* haml
* css
* sass
* js
* html

Examples:

  # searches all significant project directories for files that
  # contain the string "FIXME".
  script/find FIXME

  # searches all javascript and view files for Ajax.Request.
  script/find js Ajax.Request

  # searches the project's helpers for all method definitions
  # starting with "emit_":
  script/find helper "def emit_"
 
Copyright (c) 2009 Jamis Buck, released under the MIT license
