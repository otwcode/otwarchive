# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

begin
  require 'shoulda/tasks'
rescue Exception
  puts "shoulda gem not installed yet"
end

begin
  load File.join(RAILS_ROOT, Dir["vendor/gems/relevance-tarantula-*/tasks/*.rake"])
rescue Exception
  puts "after installing the tarantula gem, do the following to run its rake tests:"
  puts " cd vendor/gems"
  puts " gem unpack relevance-tarantula"
end
