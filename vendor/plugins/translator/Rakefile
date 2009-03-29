require 'rake'
require 'rake/testtask'
  
# Use Hanna for pretty RDocs (if installed), otherwise normal rdocs
begin
  require 'hanna/rdoctask'
rescue LoadError
  require 'rake/rdoctask'
end

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the translator plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the translator plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Translator - i18n tooling for Rails'
  rdoc.options << '--line-numbers' << '--inline-source' << '--webcvs=http://github.com/graysky/translator/tree/master/'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Publish rdocs to Github on special gh-pages branch. Assumes local branch gh-pages"
task :publish_rdoc do
  # Build the rdocs
  safe_system("rake rerdoc")
  move("rdoc", "rdoc-tmp")
  
  git("co gh-pages")
  # Remove existing docs
  git("rm -rf --quiet rdoc")
  move("rdoc-tmp", "rdoc")
  # Add new ones
  git("add .")
  # Push the changes
  git("commit -a -m 'updating rdocs'")
  git("push origin HEAD")
  
  git("co master")
  #system("open coverage/index.html") if PLATFORM['darwin']
end

def git(cmd)
  safe_system("git " + cmd)
end

def safe_system(cmd)
  if !system(cmd)
    puts "Failed: #{cmd}"
    exit
  end
end