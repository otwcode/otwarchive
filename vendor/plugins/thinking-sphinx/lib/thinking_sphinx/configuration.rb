require 'erb'

module ThinkingSphinx
  # This class both keeps track of the configuration settings for Sphinx and
  # also generates the resulting file for Sphinx to use.
  # 
  # Here are the default settings, relative to RAILS_ROOT where relevant:
  #
  # config file::           config/#{environment}.sphinx.conf
  # searchd log file::      log/searchd.log
  # query log file::        log/searchd.query.log
  # pid file::              log/searchd.#{environment}.pid
  # searchd files::         db/sphinx/#{environment}/
  # address::               127.0.0.1
  # port::                  3312
  # allow star::            false
  # min prefix length::     1
  # min infix length::      1
  # mem limit::             64M
  # max matches::           1000
  # morphology::            stem_en
  # charset type::          utf-8
  # charset table::         nil
  # ignore chars::          nil
  # html strip::            false
  # html remove elements::  ''
  #
  # If you want to change these settings, create a YAML file at
  # config/sphinx.yml with settings for each environment, in a similar
  # fashion to database.yml - using the following keys: config_file,
  # searchd_log_file, query_log_file, pid_file, searchd_file_path, port,
  # allow_star, enable_star, min_prefix_len, min_infix_len, mem_limit,
  # max_matches, # morphology, charset_type, charset_table, ignore_chars,
  # html_strip, # html_remove_elements. I think you've got the idea.
  # 
  # Each setting in the YAML file is optional - so only put in the ones you
  # want to change.
  #
  # Keep in mind, if for some particular reason you're using a version of
  # Sphinx older than 0.9.8 r871 (that's prior to the proper 0.9.8 release),
  # don't set allow_star to true.
  # 
  class Configuration
    attr_accessor :config_file, :searchd_log_file, :query_log_file,
      :pid_file, :searchd_file_path, :address, :port, :enable_star,
      :allow_star, :min_prefix_len, :min_infix_len, :mem_limit, :max_matches,
      :morphology, :charset_type, :charset_table, :ignore_chars, :html_strip,
      :html_remove_elements, :database_yml_file, :app_root
    
    attr_reader :environment
    
    # Load in the configuration settings - this will look for config/sphinx.yml
    # and parse it according to the current environment.
    # 
    def initialize(app_root = Dir.pwd)
      self.app_root          = RAILS_ROOT if defined?(RAILS_ROOT)
      self.app_root          = Merb.root  if defined?(Merb)
      self.app_root        ||= app_root
      
      self.database_yml_file    = "#{self.app_root}/config/database.yml"
      self.config_file          = "#{self.app_root}/config/#{environment}.sphinx.conf"
      self.searchd_log_file     = "#{self.app_root}/log/searchd.log"
      self.query_log_file       = "#{self.app_root}/log/searchd.query.log"
      self.pid_file             = "#{self.app_root}/log/searchd.#{environment}.pid"
      self.searchd_file_path    = "#{self.app_root}/db/sphinx/#{environment}"
      self.address              = "127.0.0.1"
      self.port                 = 3312
      self.allow_star           = false
      self.enable_star          = false
      self.min_prefix_len       = nil
      self.min_infix_len        = nil
      self.mem_limit            = "64M"
      self.max_matches          = 1000
      self.morphology           = "stem_en"
      self.charset_type         = "utf-8"
      self.charset_table        = nil
      self.ignore_chars         = nil
      self.html_strip           = false
      self.html_remove_elements = ""
      
      parse_config
    end
    
    def self.environment
      @@environment ||= (
        defined?(Merb) ? ENV['MERB_ENV'] : ENV['RAILS_ENV']
      ) || "development"
    end
    
    def environment
      self.class.environment
    end
    
    # Generate the config file for Sphinx by using all the settings defined and
    # looping through all the models with indexes to build the relevant
    # indexer and searchd configuration, and sources and indexes details.
    #
    def build(file_path=nil)
      load_models
      file_path ||= "#{self.config_file}"
      database_confs = YAML::load(ERB.new(IO.read("#{self.database_yml_file}")).result)
      database_confs.symbolize_keys!
      database_conf  = database_confs[environment.to_sym]
      database_conf.symbolize_keys!
      
      open(file_path, "w") do |file|
        file.write <<-CONFIG
indexer
{
  mem_limit = #{self.mem_limit}
}

searchd
{
  address = #{self.address}
  port = #{self.port}
  log = #{self.searchd_log_file}
  query_log = #{self.query_log_file}
  read_timeout = 5
  max_children = 30
  pid_file = #{self.pid_file}
  max_matches = #{self.max_matches}
}
        CONFIG
        
        ThinkingSphinx.indexed_models.each_with_index do |model, model_index|
          model           = model.constantize
          sources         = []
          delta_sources   = []
          prefixed_fields = []
          infixed_fields  = []
          
          model.indexes.select { |index| index.model == model }.each_with_index do |index, i|
            file.write index.to_config(model, i, database_conf, charset_type, model_index)
            
            create_array_accum if index.adapter == :postgres
            sources << "#{ThinkingSphinx::Index.name(model)}_#{i}_core"
            delta_sources << "#{ThinkingSphinx::Index.name(model)}_#{i}_delta" if index.delta?
          end
          
          next if sources.empty?
          
          source_list = sources.collect       { |s| "source = #{s}" }.join("\n")
          delta_list  = delta_sources.collect { |s| "source = #{s}" }.join("\n")
          
          file.write core_index_for_model(model, source_list)
          unless delta_list.blank?
            file.write delta_index_for_model(model, delta_list)
          end
          
          file.write distributed_index_for_model(model)
        end
      end
    end
    
    # Make sure all models are loaded - without reloading any that
    # ActiveRecord::Base is already aware of (otherwise we start to hit some
    # messy dependencies issues).
    # 
    def load_models
      base = "#{app_root}/app/models/"
      Dir["#{base}**/*.rb"].each do |file|
        model_name = file.gsub(/^#{base}([\w_\/\\]+)\.rb/, '\1')
        
        next if model_name.nil?
        next if ::ActiveRecord::Base.send(:subclasses).detect { |model|
          model.name == model_name
        }
        
        begin
          model_name.camelize.constantize
        rescue LoadError
          model_name.gsub!(/.*[\/\\]/, '').nil? ? next : retry
        rescue NameError
          next
        rescue
          puts "Thinking Sphinx could not find a valid class for #{model_name}. If this is follows a database reset it may not have been created yet. Ignoring for now."
        end
      end
    end
    
    private
    
    # Parse the config/sphinx.yml file - if it exists - then use the attribute
    # accessors to set the appropriate values. Nothing too clever.
    # 
    def parse_config
      path = "#{app_root}/config/sphinx.yml"
      return unless File.exists?(path)
      
      conf = YAML::load(ERB.new(IO.read(path)).result)[environment]
      
      conf.each do |key,value|
        self.send("#{key}=", value) if self.methods.include?("#{key}=")
      end unless conf.nil?
    end
    
    def core_index_for_model(model, sources)
      output = <<-INDEX

index #{ThinkingSphinx::Index.name(model)}_core
{
#{sources}
path = #{self.searchd_file_path}/#{ThinkingSphinx::Index.name(model)}_core
charset_type = #{self.charset_type}
INDEX
      
      morphology  = model.indexes.inject(self.morphology) { |morph, index|
        index.options[:morphology] || morph
      }
      output += "  morphology     = #{morphology}\n"         unless morphology.blank?
      output += "  charset_table  = #{self.charset_table}\n" unless self.charset_table.nil?
      output += "  ignore_chars   = #{self.ignore_chars}\n"  unless self.ignore_chars.nil?
      
      if self.allow_star
        # Ye Olde way of turning on enable_star
        output += "  enable_star    = 1\n"
        output += "  min_prefix_len = #{self.min_prefix_len}\n"
      else
        # New, better way of turning on enable_star - thanks to James Healy
        output += "  enable_star    = 1\n" if self.enable_star
        output += "  min_prefix_len = #{self.min_prefix_len}\n" unless self.min_prefix_len.nil?
        output += "  min_infix_len  = #{self.min_infix_len}\n" unless self.min_infix_len.nil?
      end
      

      output += "  html_strip     = 1\n" if self.html_strip
      output += "  html_remove_elements = #{self.html_remove_elements}\n" unless self.html_remove_elements.blank?

      unless model.indexes.collect(&:prefix_fields).flatten.empty?
        output += "  prefix_fields = #{model.indexes.collect(&:prefix_fields).flatten.map(&:unique_name).join(', ')}\n"
      else
        output += " prefix_fields = _\n" unless model.indexes.collect(&:infix_fields).flatten.empty?
      end
      
      unless model.indexes.collect(&:infix_fields).flatten.empty?
        output += "  infix_fields  = #{model.indexes.collect(&:infix_fields).flatten.map(&:unique_name).join(', ')}\n"
      else
        output += " infix_fields = -\n" unless model.indexes.collect(&:prefix_fields).flatten.empty?
      end
      
      output + "}\n"
    end
    
    def delta_index_for_model(model, sources)
      <<-INDEX
index #{ThinkingSphinx::Index.name(model)}_delta : #{ThinkingSphinx::Index.name(model)}_core
{
  #{sources}
  path = #{self.searchd_file_path}/#{ThinkingSphinx::Index.name(model)}_delta
}
      INDEX
    end
    
    def distributed_index_for_model(model)
      sources = ["local = #{ThinkingSphinx::Index.name(model)}_core"]
      if model.indexes.any? { |index| index.delta? }
        sources << "local = #{ThinkingSphinx::Index.name(model)}_delta"
      end
      
      <<-INDEX
index #{ThinkingSphinx::Index.name(model)}
{
  type = distributed
  #{ sources.join("\n  ") }
  charset_type = #{self.charset_type}
}
      INDEX
    end
    
    def create_array_accum
      ::ActiveRecord::Base.connection.execute "begin"
      ::ActiveRecord::Base.connection.execute "savepoint ts"
      begin
        ::ActiveRecord::Base.connection.execute <<-SQL
          CREATE AGGREGATE array_accum (anyelement)
          (
              sfunc = array_append,
              stype = anyarray,
              initcond = '{}'
          );
        SQL
      rescue
        raise unless $!.to_s =~ /already exists with same argument types/
        ::ActiveRecord::Base.connection.execute "rollback to savepoint ts"
      end
      ::ActiveRecord::Base.connection.execute "release savepoint ts"
      ::ActiveRecord::Base.connection.execute "commit"
    end
  end
end
