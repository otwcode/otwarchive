require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'
require 'rubygems'
gem "spicycode-micronaut", ">= 0.2.0"
require 'micronaut'
require 'micronaut/rake_task'
require 'lib/relevance/tarantula.rb'

begin
  require 'jeweler'
  files = ["CHANGELOG", "MIT-LICENSE", "Rakefile", "README.rdoc", "VERSION.yml"]
  files << Dir["examples/**/*", "laf/**/*", "lib/**/*", "tasks/**/*", "template/**/*"]
  
  Jeweler::Tasks.new do |s|
    s.name = "tarantula"
    s.summary = "A big hairy fuzzy spider that crawls your site, wreaking havoc"
    s.description = "A big hairy fuzzy spider that crawls your site, wreaking havoc"
    s.homepage = "http://github.com/relevance/tarantula"
    s.email = "opensource@thinkrelevance.com"
    s.authors = ["Relevance, Inc."]
    s.require_paths = ["lib"]
    s.files = files.flatten
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc 'Generate documentation for the tarantula plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Tarantula'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Run all micronaut examples"
Micronaut::RakeTask.new :examples do |t|
  t.pattern = "examples/**/*_example.rb"
end

namespace :examples do
  desc "Run all micronaut examples using rcov"
  Micronaut::RakeTask.new :coverage do |t|
    t.pattern = "examples/**/*_example.rb"
    t.rcov = true
    t.rcov_opts = %[--exclude "gems/*,/Library/Ruby/*,config/*" --text-summary  --sort coverage --no-validator-links]
  end
end

task :default => "examples"
