module MultiRails

  class Loader
    attr_reader :version
    
    def self.logger
      @logger ||= Logger.new(STDOUT)
    end
    
    # Require and gem rails
    # Will use a default version if none is supplied
    def self.gem_and_require_rails(rails_version = nil)
      rails_version = MultiRails::Config.version_lookup(rails_version)
      Loader.new(rails_version).gem_and_require_rails
    end
    
    # Returns a list of all Rails versions available, oldest first
    def self.all_rails_versions
      specs = Gem::cache.find_name("rails")
      specs.map {|spec| spec.version.to_s }.sort
    end
    
    # Try to detech the latest stable by finding the most recent version with less then 4 version parts
    #  -- not sure if there is a better way?
    def self.latest_stable_version
      all_rails_versions.sort.reverse.detect {|version| version.count(".") < 3 }
    end
    
    # Find the most recent version
    def self.latest_version
      all_rails_versions.sort.last
    end
    
    # A version of the loader is created to gem and require one version of Rails
    def initialize(version)
      @version = version
    end
    
    # Gem a version of Rails, and require appropriate files
    def gem_and_require_rails
      gem_rails
      require_rails
      display_rails_gem_used
    end
    
    # Display the rails gem from the laod path, as a sanity check to make sure we are getting the rails version we expect
    def display_rails_gem_used
      puts %[#{MultiRails::BAR}\nUsing rails gem: #{Config.rails_load_path}\n]
    end
    
    def gem_rails
      gem 'rails', version
    rescue LoadError => e
      msg = %Q[Cannot find gem for Rails version: '#{version}'!\nInstall the missing gem with:\nsudo gem install -v=#{version} rails]
      raise MultiRailsError, msg
    end
    
    def require_rails
      Config.rails_requires.each {|lib| require lib }
    end
  end
  
end