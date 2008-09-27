require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => [:clean, :test]

desc "Delete test-generated files"
task :clean do
  %w(sqlite sqlite3).each do |db_name|
    rm_f File.join(File.dirname(__FILE__), "squirrel.#{db_name}.db")
  end
  rm_f File.join(File.dirname(__FILE__), 'test', 'debug.log')
end

desc 'Test the squirrel plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc "Clean the docs directory"
task :clean_docs do
  `rm -rf doc/`
end

desc 'Generate documentation for the squirrel plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'Squirrel'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Update documentation on website'
task :sync_docs => [:clean_docs, :rdoc] do
  `rsync -ave ssh doc/ dev@dev.thoughtbot.com:/home/dev/www/dev.thoughtbot.com/squirrel`
end

