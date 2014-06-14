# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
require 'resque/tasks'

include Rake::DSL
Otwarchive::Application.load_tasks

# Coveralls and SimpleCov require additional config options here.
# All test coverage is gathered and held until all suites are done
# then the data is pushed to Coveralls.io.

require 'coveralls/rake/task'
Coveralls::RakeTask.new
task :test_with_coveralls => [:spec, :features, 'coveralls:push']
