require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require 'rake/contrib/rubyforgepublisher'

desc 'Default: run unit tests.'
task :default => :spec

# Create specs + Rake Task

def doc_directory
  "doc"
end

desc 'Generate documentation for the fixture_replacement plugin.'
Rake::RDocTask.new(:rdoc_without_analytics) do |rdoc|
  rdoc.rdoc_dir = doc_directory
  rdoc.title    = 'FixtureReplacement'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :rdoc => [:rdoc_without_analytics] do
  google_analytics = File.read(File.dirname(__FILE__) + "/etc/google_analytics")
  rdoc_index = File.dirname(__FILE__) + "/#{doc_directory}/index.html"
  
  contents = File.read(rdoc_index) 
  contents.gsub!("</head>", "#{google_analytics}\n</head>")

  File.open(rdoc_index, "r+") do |file|
    file.write(contents)
  end

end

task :rerdoc => [:clobber_rdoc, :rdoc]
task :clobber_rdoc => [:clobber_rdoc_without_analytics]

desc 'Run the specs'
Spec::Rake::SpecTask.new do |t|
  t.warning = false
  t.spec_opts = ["--color"]
end

desc 'Publish the website, building the docs first'
task :publish_website => [:build_docs] do
  publisher = Rake::SshDirPublisher.new(
    "smtlaissezfaire@rubyforge.org",
    "/var/www/gforge-projects/replacefixtures/",
    "doc"
  )
  publisher.upload
end

def create_doc_directory
  unless File.exists?(doc_directory)
    `mkdir doc`
  end  
end

task :create_doc_directory do
  create_doc_directory
end

desc "Create the html specdoc"
Spec::Rake::SpecTask.new(:specdoc => :create_doc_directory) do |t|
  t.spec_opts = ["--format", "html:doc/specdoc.html"]
end

desc 'Create the specdoc + rdoc'
task :build_docs => [:rerdoc, :specdoc, :rcov, :flog_to_disk]

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new(:rcov) do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
  t.rcov_dir = "doc/rcov"
end

desc "Feel the pain of my code, and submit a refactoring patch"
task :flog do
  puts %x(find lib | grep ".rb$" | xargs flog)
end

task :flog_to_disk => :create_doc_directory do
  puts "Flogging..."
  %x(find lib | grep ".rb$" | xargs flog > doc/flog.txt)
  puts "Done Flogging...\n"
end