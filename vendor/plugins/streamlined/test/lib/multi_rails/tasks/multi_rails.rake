require 'rubygems'
require 'rake'
require 'rake/testtask'
require File.expand_path(File.join(File.dirname(__FILE__), "/../lib/multi_rails"))

# Enable overriding the already invoked flag of a Rake task
class Rake::Task
  attr_accessor :already_invoked
end

namespace :test do
  namespace :multi_rails do

    desc "Run against all installed versions of Rails.  Local versions found: [#{MultiRails::Loader.all_rails_versions.to_sentence}]."
    task :all do
      begin
        failed_versions = []
        MultiRails::Loader.all_rails_versions.each_with_index do |version, index|
          silence_warnings { ENV["MULTIRAILS_RAILS_VERSION"] = version }
          init_for_rails_app(version) if within_rails_app?
          print_rails_version
          reset_test_tasks unless index == 0
          begin
            Rake::Task[:test].invoke
          rescue RuntimeError => e
            puts e.message
            failed_versions << version
          end
        end
        abort("Build failed with Rails versions: [#{failed_versions.to_sentence}].") if failed_versions.any?
      ensure
        clean_up
      end
    end
    
    desc "Run against one verison of Rails specified as 'MULTIRAILS_RAILS_VERSION' - for example 'rake test:multi_rails:one MULTIRAILS_RAILS_VERSION=1.2.3'"
    task :one do
      begin
        version = ENV["MULTIRAILS_RAILS_VERSION"]
        raise "Must give a version number" unless version
        init_for_rails_app(version) if within_rails_app?
        print_rails_version
        Rake::Task[:test].invoke
      ensure
        clean_up
      end
    end
    
    desc "Run against the most recent version of Rails installed.  Most recent found: [#{MultiRails::Loader.latest_version}]."
    task :latest do
      begin
        version = MultiRails::Loader.latest_version
        ENV["MULTIRAILS_RAILS_VERSION"] = version
        init_for_rails_app(version) if within_rails_app?
        print_rails_version
        Rake::Task[:test].invoke
      ensure
        clean_up
      end
    end
    
    def init_for_rails_app(version)
      MultiRails::RailsAppHelper.init_for_rails_app(version)
      load "Rakefile"
    end
    
    def within_rails_app?
      ENV["MULTIRAILS_FOR_RAILS_APP"] == "true"
    end
    
    # clean up after ourselves, reverting to clean state if needed
    def clean_up
      MultiRails::RailsAppHelper.clean_up if within_rails_app?
    end
    
    def print_rails_version
      puts "\n#{MultiRails::BAR}\nTesting with Rails #{MultiRails::Config.version_lookup}\n#{MultiRails::BAR}"
    end
    
    # Need to hack the Rake test task a bit, otherwise it will only run once and never repeat.
    def reset_test_tasks
      ["test", "test:units", "test:functionals", "test:integration"].each do |name| 
        if Rake::Task.task_defined?(name)
          Rake::Task[name].already_invoked = false
          Rake::Task[name].prerequisites.each {|p| Rake::Task[p].already_invoked = false}
        end
      end
    end
    
  end
end