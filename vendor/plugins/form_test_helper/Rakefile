require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the form_test_helper plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the form_test_helper plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'FormTestHelper'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace :rdoc do
  desc 'Generate and deploy documentation to rubyforge.'
  task :deploy do
    require 'fileutils'
    require 'yaml'
    svn_info = YAML.load(`svn info`)
    dir = File.basename(svn_info['URL'])
    revision = svn_info['Revision'].to_s
    
    # add revision to generated README
    contents = IO.read("README")
    File.open("README", "w"){ |f| f.puts contents.dup.gsub("$revision", revision)}
    Rake::Task[:rdoc].invoke
    
    tempdir = "/tmp/#{dir}_rdoc"
    rdocdir = tempdir + "/#{dir}"
    FileUtils.mkdir_p rdocdir
    FileUtils.mv "rdoc", rdocdir

    system "rsync -avz --delete #{rdocdir} rubyforge.org:/var/www/gforge-projects/continuous/"

    at_exit do
      File.open("README", "w"){ |f| f.puts contents }
      FileUtils.rm_rf tempdir if File.exists?(tempdir)
    end
  end
end

desc "cruisecontrol.rb"
task :cruise do  
  `rm -fr ../dummy_rails_project/vendor/plugins/form_test_helper`
  `mkdir -p ../dummy_rails_project/vendor/plugins/form_test_helper`  
  `cp -fr * ../dummy_rails_project/vendor/plugins/form_test_helper/`  
  Dir.chdir('../dummy_rails_project/')  
  `rake rails:freeze:edge`  
  Dir.chdir('vendor/plugins/form_test_helper')  
  Rake::Task[:test].invoke
end