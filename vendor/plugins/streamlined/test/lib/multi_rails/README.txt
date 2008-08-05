MultiRails
    by Relevance, http://thinkrelevance.com
       Rob Sanheim - MultiRails lead

MultiRails lets you test your Rails plugin or app against many versions of Rails in one sweep.

== URLs:

  rubyforge:    http://rubyforge.org/projects/multi-rails/
  rdocs:        http://multi-rails.rubyforge.org/
  svn stable:   http://robsanheim.googlecode.com/svn/tags/stable/multi_rails (gem is released from here)
  svn trunk:    http://robsanheim.googlecode.com/svn/trunk/multi_rails
  mailing list: http://groups.google.com/group/multi_rails
  
== DESCRIPTION:
  
MultiRails allows easy testing against multiple versions of Rails for your Rails specific gem or plugin.  IT also has tentative support testing Rails applications against multiple versions of Rails.

Use MultiRails to hook in Rails 2.0 testing in your continuous integration.  Still working on Rails 2.0 support?  Use MultiRails to see where your test suite falls down against the 2.0 preview releases of Rails.

MultiRails was initially developed by members of Relevance while developing Streamlined against edge Rails.  To see how Streamlined uses MultiRails, go to http://trac.streamlinedframework.org.

== FEATURES:

* easily test plugins/extensions using a require from your test_helper.rb and a require in your RakeFile
* rake tasks to test against a specified version of Rails, the latest version, or all versions
* tentative support for testing plain Rails apps against multiple versions of Rails
* Uses rubygems for version management of Rails

== TODOs:

* improve docs on how to override what files are required by multi_rails
* maybe add ability to load plain Rails versions -- ie checked out copies not in RubyGems

== NOTES:

* (__For Rails apps only__) multi_rails will rename your vendor/rails directory to vendor/rails.off if it finds one within your rails app.  We have to do this to make Rails fall back to RubyGems rails.  Multi_rails will rename back to the correct vendor/rails when done testing, so it will not interrupt your app in normal use.
* (__For Rails apps only__) multi_rails needs to add a line to top of your environment.rb to hook into -- see the instructions below for more details

== REQUIREMENTS:

* Ruby 1.8.5 or higher
* Rubygems
* Rails 1.2.1 or higher
* at least one copy of Rails installed via rubygems.

== INSTALLING FOR RAILS APPS

* install the plugin, which will copy the multi_rails_runner into your script folder on install.
    script/plugin install http://robsanheim.googlecode.com/svn/tags/stable/multi_rails

* Run the multi_rails bootstrap command to get your Rails app ready to go with multi_rails - this will add a require line to the top of your environment.rb needed for multi_rails to work right.
    script/multi_rails_runner bootstrap

* Run your tests against all versions of Rails installed (the default):
    script/multi_rails_runner
  or run our tests against the most recent version of Rails you have installed:
    script/multi_rails_runner latest
  or just a specific version:
    MULTIRAILS_RAILS_VERSION=1.2.5 script/multi_rails_runner one

== INSTALLING FOR PLUGINS

* Install multi_rails
    sudo gem install multi_rails

* In your projects Rakefile, require the multi_rails Rake tasks.

  require "load_multi_rails_rake_tasks"

* Run rake -T to verify you see the multi_rails tasks.
    rake -T multi_rails
    # should see   "rake test:multi_rails:all, rake test:multi_rails:latest...etc"

* In your test_helper, require multi_rails_init *before* any rails specific requires (activerecord, actioncontroller, activesupport, etc).

  require 'multi_rails_init'

* Run the multi_rails:all rake task to run your test suite against all versions of Rails you have installed via gems.  Install other versions of Rails using rubygems to add them to your test suite.

* For changing the Rails version under test, set the environment variable MULTIRAILS_RAILS_VERSION to version you want, and run the multi_rails:one task or just run a test class directly.

== HELP

* Join the mailing list!  
  http://groups.google.com/group/multi_rails
  multi_rails@googlegroups.com

* Rails plugin testing is pretty solid, but rails *app* testing is still new.  Post issues to the mailing list.
* Getting gem activation errors?  Post to the list with how you are using multi_rails, and I'll try to help.

== LICENSE:

(The MIT License)

Copyright (c) 2007 Relevance, http://thinkrelevance.com

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
