require 'find'

# Handle copying over the default assets, views, and layout that Streamlined depends on.
# We don't do all this in the rake task to make things easier to test.
module Streamlined
  class Assets
    @source = File.expand_path(File.join(File.dirname(__FILE__), '..', 'files'))
    @destination = RAILS_ROOT
    class << self 
      attr_accessor :source, :destination
    end

    # Copy the files from streamlined into the Rails project
    # Ignores any files or directories that start with a period (so .svn will get ignored),
    # also will ignore CVS metadata.
    def self.install
      paths = []
      Find.find(source) do |path|
        Find.prune if path =~ /\/\..+/
        Find.prune if path =~ /CVS/
        paths << path
      end
      paths.each do |path| 
        dest_path = path.gsub(source, destination)
        if File.directory?(path)
          FileUtils.mkdir_p(dest_path) unless File.exists?(dest_path)
        else
          FileUtils.cp(path, dest_path)
        end
      end
    rescue Exception => e
      puts "Error trying to copy files: #{e.inspect}"
      raise e
    end
    
  end  
end

namespace :streamlined do
  
  desc 'Install Streamlined required files.'
  task :install_files do  
    Streamlined::Assets.install
  end
  
  desc 'Create the StreamlinedUI file for one or more models.'
  task :model => :environment do
    raise "Must specify at least one model name using MODEL=." unless ENV['MODEL']
    
    ui_template = ERB.new <<-TEMPLATE
module <%= model %>Additions

end
<%= model %>.class_eval { include <%= model %>Additions }

Streamlined.ui_for(<%= model %>) do

end   
    TEMPLATE

    unless FileTest.exist? File.join(RAILS_ROOT, 'app', 'streamlined')
      FileUtils.mkdir(File.join(RAILS_ROOT, 'app', 'streamlined'))
    end

    ENV['MODEL'].split(',').each do |model|
      file_name = "#{model.underscore}_ui.rb"

      unless FileTest.exist? File.join(RAILS_ROOT, 'app', 'streamlined', file_name)
          File.open(File.join(RAILS_ROOT, 'app', 'streamlined', file_name), "a") { |f|
             f << ui_template.result(binding)
          }
      end
    end
  end
end