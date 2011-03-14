# coding: utf-8
require 'rake'
require 'rake/rdoctask'

gem 'rspec-rails', '>= 1.0.0'
require 'spec/rake/spectask'

NAME = "delayed_job_mailer"
SUMMARY = %Q{Send emails asynchronously using delayed_job.}
HOMEPAGE = "http://github.com/andersondias/#{NAME}"
AUTHOR = "Anderson Dias"
EMAIL = "andersondaraujo@gmail.com"
SUPPORT_FILES = %w(README)

begin
  gem 'technicalpickles-jeweler', '>= 1.2.1'
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = NAME
    gem.summary = SUMMARY
    gem.description = SUMMARY
    gem.homepage = HOMEPAGE
    gem.author = AUTHOR
    gem.email = EMAIL
    
    gem.require_paths = %w{lib}
    gem.files = SUPPORT_FILES << %w(MIT-LICENSE Rakefile) << Dir.glob(File.join('{generators,lib,test,rails}', '**', '*'))
    gem.executables = %w()
    gem.extra_rdoc_files = SUPPORT_FILES
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc %Q{Default: Run specs for "#{NAME}".}
task :default => :spec

SPEC_FILES = Rake::FileList[File.join('spec', '**', '*_spec.rb')]

desc %Q{Run specs for "#{NAME}".}
Spec::Rake::SpecTask.new do |t|
  t.spec_files = SPEC_FILES
  t.spec_opts = ['-c']
end

desc %Q{Generate code coverage for "#{NAME}".}
Spec::Rake::SpecTask.new(:coverage) do |t|
  t.spec_files = SPEC_FILES
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,/var/lib/gems']
end

desc %Q{Generate documentation for "#{NAME}".}
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = NAME
  rdoc.options << '--line-numbers' << '--inline-source' << '--charset=UTF-8'
  rdoc.rdoc_files.include(SUPPORT_FILES)
  rdoc.rdoc_files.include(File.join('lib', '**', '*.rb'))
end
