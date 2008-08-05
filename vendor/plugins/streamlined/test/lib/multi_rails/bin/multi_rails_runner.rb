#!/usr/bin/env ruby
require 'rake'
require 'rake/testtask'
require 'pathname'

# Get the real path, to make sure if this file is symlinked we don't mess up
absolute_current_dir = File.dirname(Pathname.new(__FILE__).realpath)

require File.expand_path(File.join(absolute_current_dir, "../lib/multi_rails"))
require File.expand_path(File.join(absolute_current_dir, "../tasks/load_multi_rails_rake_tasks"))

# A script to allow multi_rails to work with Rails apps
# For testing Rails plugins or gems, you don't need to use this - you can just the rake tasks.
module MultiRails
  module Runner
    # Run multi_rails using the specified task, defaults to testing against all Rails versions intalled
    def self.run(task = "all")
      task = task ? task : "all"
      puts %[Running MultiRails with task "#{task}"...]
      MultiRails::RailsAppHelper.run(task)
    end
    
  end
end

HELP_MESSAGE = "Give this runner the name of the multi_rails rake task you want to run, or give it no args if you want the default behavior of testing against all versions of Rails."

if ARGV.size > 1
  puts HELP_MESSAGE
else
  MultiRails::Runner.run(ARGV.first)
end