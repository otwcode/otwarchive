=begin
------------------------------------------------------------- Class: Gem
     Main module to hold all RubyGem classes/modules.

------------------------------------------------------------------------


Constants:
----------
     MD5:                    Digest::MD5
     MD5:                    DigestAdapter.new(Digest::MD5)
     SHA1:                   Digest::SHA1
     SHA1:                   DigestAdapter.new(Digest::SHA1)
     SHA256:                 Digest::SHA256
     SHA256:                 DigestAdapter.new(Digest::SHA256)
     HELP:                   %{     RubyGems is a sophisticated package
                             manager for Ruby.  This is a     basic help
                             message containing pointers to more
                             information.        Usage:         gem
                             -h/--help         gem -v/--version        
                             gem command [arguments...] [options...]    
                                Examples:         gem install rake      
                               gem list --local         gem build
                             package.gemspec         gem help install   
                                 Further help:         gem help commands
                                        list all 'gem' commands        
                             gem help examples            show some
                             examples of usage         gem help
                             <COMMAND>           show help on COMMAND   
                                                                 (e.g.
                             'gem help install')       Further
                             information:        
                             http://rubygems.rubyforge.org     }.gsub(/^
                                /, "")
     EXAMPLES:               %{     Some examples of 'gem' usage.      *
                             Install 'rake', either from local directory
                             or remote server:              gem install
                             rake      * Install 'rake', only from
                             remote server:          gem install rake
                             --remote      * Install 'rake' from remote
                             server, and run unit tests,       and
                             generate RDocs:          gem install
                             --remote rake --test --rdoc --ri      *
                             Install 'rake', but only version 0.3.1,
                             even if dependencies       are not met, and
                             into a specific directory:          gem
                             install rake --version 0.3.1 --force
                             --install-dir $HOME/.gems      * List local
                             gems whose name begins with 'D':         
                             gem list D      * List local and remote
                             gems whose name contains 'log':         
                             gem search log --both      * List only
                             remote gems whose name contains 'log':     
                                 gem search log --remote      *
                             Uninstall 'rake':          gem uninstall
                             rake          * Create a gem:          See
                             http://rubygems.rubyforge.org/wiki/wiki.pl?
                             CreateAGemInTenMinutes      * See
                             information about RubyGems:             
                             gem environment      }.gsub(/^    /, "")
     RubyGemsVersion:        '0.9.4'
     Cache:                  SourceIndex
     Requirement:            ::Gem::Version::Requirement
     MUTEX:                  Mutex.new
     RubyGemsPackageVersion: RubyGemsVersion
     DIRECTORIES:            ['cache', 'doc', 'gems', 'specifications']


Class methods:
--------------
     activate, all_load_paths, bindir, clear_paths, config_file,
     configuration, configuration=, configure, datadir, default_dir,
     dir, ensure_ssl_available, latest_load_paths, load_commands,
     manage_gems, path, required_location, ruby, searcher, source_index,
     ssl_available?, suffix_pattern, suffixes, use_paths, user_home

Attributes:
     loaded_specs, ssl_available

=end
module Gem

  # --------------------------------------------------------- Gem::use_paths
  #      Gem::use_paths(home, paths=[])
  # ------------------------------------------------------------------------
  #      Use the +home+ and (optional) +paths+ values for +dir+ and +path+.
  #      Used mainly by the unit tests to provide environment isolation.
  # 
  def self.use_paths(arg0, arg1, arg2, *rest)
  end

  # ---------------------------------------------------- Gem::ssl_available?
  #      Gem::ssl_available?()
  # ------------------------------------------------------------------------
  #      Is SSL (used by the signing commands) available on this platform?
  # 
  def self.ssl_available?
  end

  # ----------------------------------------------------------- Gem::datadir
  #      Gem::datadir(gem_name)
  # ------------------------------------------------------------------------
  #      Return the path the the data directory specified by the gem name.
  #      If the package is not available as a gem, return nil.
  # 
  def self.datadir(arg0)
  end

  def self.loaded_specs
  end

  # -------------------------------------------------------------- Gem::ruby
  #      Gem::ruby()
  # ------------------------------------------------------------------------
  #      Return the Ruby command to use to execute the Ruby interpreter.
  # 
  def self.ruby
  end

  # ---------------------------------------------------- Gem::all_load_paths
  #      Gem::all_load_paths()
  # ------------------------------------------------------------------------
  #      Return a list of all possible load paths for all versions for all
  #      gems in the Gem installation.
  # 
  def self.all_load_paths
  end

  # ---------------------------------------------------------- Gem::suffixes
  #      Gem::suffixes()
  # ------------------------------------------------------------------------
  #      (no description...)
  def self.suffixes
  end

  # -------------------------------------------------------------- Gem::path
  #      Gem::path()
  # ------------------------------------------------------------------------
  #      List of directory paths to search for Gems.
  # 
  #      return: [List<String>] List of directory paths.
  # 
  def self.path
  end

  # ---------------------------------------------------------- Gem::searcher
  #      Gem::searcher()
  # ------------------------------------------------------------------------
  #      Return the searcher object to search for matching gems.
  # 
  def self.searcher
  end

  # ------------------------------------------------------- Gem::clear_paths
  #      Gem::clear_paths()
  # ------------------------------------------------------------------------
  #      Reset the +dir+ and +path+ values. The next time +dir+ or +path+ is
  #      requested, the values will be calculated from scratch. This is
  #      mainly used by the unit tests to provide test isolation.
  # 
  def self.clear_paths
  end

  # ------------------------------------------------- Gem::required_location
  #      Gem::required_location(gemname, libfile, *version_constraints)
  # ------------------------------------------------------------------------
  #      (no description...)
  def self.required_location(arg0, arg1, arg2, arg3, *rest)
  end

  # ------------------------------------------------------------ Gem::bindir
  #      Gem::bindir(install_dir=Gem.dir)
  # ------------------------------------------------------------------------
  #      The directory path where executables are to be installed.
  # 
  def self.bindir(arg0, arg1, *rest)
  end

  # ----------------------------------------------------- Gem::configuration
  #      Gem::configuration()
  # ------------------------------------------------------------------------
  #      The standard configuration object for gems.
  # 
  def self.configuration
  end

  # --------------------------------------------------------------- Gem::dir
  #      Gem::dir()
  # ------------------------------------------------------------------------
  #      The directory path where Gems are to be installed.
  # 
  #      return: [String] The directory path
  # 
  def self.dir
  end

  # --------------------------------------------------------- Gem::user_home
  #      Gem::user_home()
  # ------------------------------------------------------------------------
  #      The home directory for the user.
  # 
  def self.user_home
  end

  # ---------------------------------------------- Gem::ensure_ssl_available
  #      Gem::ensure_ssl_available()
  # ------------------------------------------------------------------------
  #      Ensure that SSL is available. Throw an exception if it is not.
  # 
  def self.ensure_ssl_available
  end

  # ------------------------------------------------------ Gem::source_index
  #      Gem::source_index()
  # ------------------------------------------------------------------------
  #      Returns an Cache of specifications that are in the Gem.path
  # 
  #      return: [Gem::SourceIndex] Index of installed Gem::Specifications
  # 
  def self.source_index
  end

  def self.ssl_available=(arg0)
  end

  # ------------------------------------------------------- Gem::config_file
  #      Gem::config_file()
  # ------------------------------------------------------------------------
  #      Return the path to standard location of the users .gemrc file.
  # 
  def self.config_file
  end

  # ---------------------------------------------------- Gem::configuration=
  #      Gem::configuration=(config)
  # ------------------------------------------------------------------------
  #      Use the given configuration object (which implements the ConfigFile
  #      protocol) as the standard configuration object.
  # 
  def self.configuration=(arg0)
  end

  # ------------------------------------------------------- Gem::default_dir
  #      Gem::default_dir()
  # ------------------------------------------------------------------------
  #      Default home directory path to be used if an alternate value is not
  #      specified in the environment.
  # 
  def self.default_dir
  end

  def self.cache
  end

  # ------------------------------------------------- Gem::latest_load_paths
  #      Gem::latest_load_paths()
  # ------------------------------------------------------------------------
  #      Return a list of all possible load paths for the latest version for
  #      all gems in the Gem installation.
  # 
  def self.latest_load_paths
  end

  # ------------------------------------------------------- Gem::manage_gems
  #      Gem::manage_gems()
  # ------------------------------------------------------------------------
  #      (no description...)
  def self.manage_gems
  end

  # ---------------------------------------------------------- Gem::activate
  #      Gem::activate(gem, autorequire, *version_requirements)
  # ------------------------------------------------------------------------
  #      Activate a gem (i.e. add it to the Ruby load path). The gem must
  #      satisfy all the specified version constraints. If +autorequire+ is
  #      true, then automatically require the specified autorequire file in
  #      the gem spec.
  # 
  #      Returns true if the gem is loaded by this call, false if it is
  #      already loaded, or an exception otherwise.
  # 
  def self.activate(arg0, arg1, arg2, arg3, *rest)
  end

  # ---------------------------------------------------- Gem::suffix_pattern
  #      Gem::suffix_pattern()
  # ------------------------------------------------------------------------
  #      (no description...)
  def self.suffix_pattern
  end

end
