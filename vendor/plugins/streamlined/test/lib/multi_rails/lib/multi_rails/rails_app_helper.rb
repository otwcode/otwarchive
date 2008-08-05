require 'rake'
module MultiRails
  module RailsAppHelper
    RAILS_DIRECTORIES = %w(app config public test)    
    REQUIRE_LINE = %[require File.expand_path('config/rails_version') if File.exist?("config/rails_version.rb")].freeze

    class << self
      
      # Run the appropriate task or method for MultiRails
      # This is called from the MultiRails command line runner
      def run(task)
        if task == "bootstrap"
          self.bootstrap_for_rails
        else
          ENV["MULTIRAILS_FOR_RAILS_APP"] = "true"
          Rake::Task["test:multi_rails:#{task}"].invoke
        end
      end
      
      # Do a one time bootstrap to let MultiRails do its thing -- we aren't putting this
      # in the general MultiRails rake file to keep it from showing up in contexts where
      # it doesn't make sense (ie when testing a plugin).
      def bootstrap_for_rails
        set_rails_root
        add_require_line_to_environment_file
      end
      
      # Make sure we have RAILS_ROOT set - will try to find it dynamically if its not set.
      def set_rails_root
        if Object.const_defined?("RAILS_ROOT")
          RAILS_ROOT
        else
          Object.const_set("RAILS_ROOT", find_rails_root_dir)
        end
        raise("Must have a valid RAILS_ROOT.") unless Object.const_defined?("RAILS_ROOT") && RAILS_ROOT
        RAILS_ROOT
      end
      
      def clean_up
        FileUtils.rm(rails_gem_version_file) if within_rails_app? && File.exist?(rails_gem_version_file)
        rename_vendor_rails_to_original
      end
      
      def init_for_rails_app(version)
        set_rails_root
        write_rails_gem_version_file(version)
        rename_vendor_rails_if_necessary
      end

      def find_rails_root_dir
        if current_dir_contains_rails_dirs? then Dir.pwd end
      end
      
      def current_dir_contains_rails_dirs?
        if RAILS_DIRECTORIES.all? { |rails_dir| Dir.entries(Dir.pwd).include?(rails_dir) }
          Dir.pwd
        end
      end
      
      # Write out a file which is loaded later, so that the RAILS_GEM_VERSION gets set in the correct process
      def write_rails_gem_version_file(version)
        File.open(rails_gem_version_file, 'w') do |file|
          file << %|RAILS_GEM_VERSION = '#{version}' unless Object.const_defined?("RAILS_GEM_VERSION")|
        end
      end
      
      def rails_gem_version_file
        File.expand_path("#{RAILS_ROOT}/config/rails_version.rb")
      end
      
      def rename_vendor_rails_if_necessary
        File.rename(vendor_rails, vendor_rails_off) if File.directory?(vendor_rails)
      end
      
      def rename_vendor_rails_to_original
        File.rename(vendor_rails_off, vendor_rails) if File.directory?(vendor_rails_off)
      end
      
      def add_require_line_to_environment_file
        raise MultiRailsError, "Can't find environment.rb file was looking at path: #{environment_file}" unless File.exist?(environment_file)
        unless first_environment_line == REQUIRE_LINE
          original_content = File.read(environment_file)
          File.open(environment_file, 'r+') do |f| 
            f.puts REQUIRE_LINE
            f.print original_content
          end
        end
      end
      
      def first_environment_line
        File.open(environment_file).readline.strip
      end
      
      def environment_file
        File.expand_path(File.join(RAILS_ROOT, "config/environment.rb"))
      end
      
      def vendor_rails
        "#{RAILS_ROOT}/vendor/rails"
      end
      
      def vendor_rails_off
        "#{RAILS_ROOT}/vendor/rails.off"
      end
    end
    
  end
end