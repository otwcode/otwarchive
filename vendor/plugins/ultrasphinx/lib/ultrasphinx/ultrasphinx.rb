
module Ultrasphinx

  class Error < ::StandardError #:nodoc:
  end
  class ConfigurationError < Error #:nodoc:
  end  
  class DaemonError < Error #:nodoc:
  end
  class UsageError < Error #:nodoc:
  end

  # Internal file paths
  
  SUBDIR = "config/ultrasphinx"
  
  DIR = "#{RAILS_ROOT}/#{SUBDIR}"
  
  THIS_DIR = File.expand_path(File.dirname(__FILE__))

  CONF_PATH = "#{DIR}/#{RAILS_ENV}.conf"
  
  ENV_BASE_PATH = "#{DIR}/#{RAILS_ENV}.base" 
  
  GENERIC_BASE_PATH = "#{DIR}/default.base"
  
  BASE_PATH = (File.exist?(ENV_BASE_PATH) ? ENV_BASE_PATH : GENERIC_BASE_PATH)
  
  raise ConfigurationError, "Please create a '#{SUBDIR}/#{RAILS_ENV}.base' or '#{SUBDIR}/default.base' file in order to use Ultrasphinx in your #{RAILS_ENV} environment." unless File.exist? BASE_PATH # XXX lame

  # Some miscellaneous constants

  MAX_INT = 2**32-1

  MAX_WORDS = 2**16 # maximum number of stopwords built  
  
  UNIFIED_INDEX_NAME = "complete"

  CONFIG_MAP = {
    # These must be symbols for key mapping against Rails itself
    :username => 'sql_user',
    :password => 'sql_pass',
    :host => 'sql_host',
    :database => 'sql_db',
    :port => 'sql_port',
    :socket => 'sql_sock'
  }
  
  CONNECTION_DEFAULTS = {
    :host => 'localhost'
  }
     
  mattr_accessor :with_rake
  
  def self.load_stored_procedure(name)
    open("#{THIS_DIR}/postgresql/#{name}.sql").read.gsub(/\s+/, ' ')
  end

  SQL_FUNCTIONS = {
    'mysql' => {
      'group_concat' => "CAST(GROUP_CONCAT(DISTINCT ? SEPARATOR ' ') AS CHAR)",
      'hash' => "CAST(CRC32(?) AS unsigned)",
      'range_cast' => "?",
      'stored_procedures' => {}
    },
    'postgresql' => {
      'group_concat' => "GROUP_CONCAT(?)",
      'range_cast' => "cast(coalesce(?,1) AS integer)",
      'hash' => "CRC32(?)",
      'stored_procedures' => Hash[*(
        ['hex_to_int', 'group_concat', 'concat_ws', 'unix_timestamp', 'crc32'].map do |name|
          [name, load_stored_procedure(name)]
        end.flatten
        )
      ]
    }      
  }
  
  DEFAULTS = {
    'mysql' => %(
type = mysql
sql_query_pre = SET SESSION group_concat_max_len = 65535
sql_query_pre = SET NAMES utf8
  ), 
    'postgresql' => %(
type = pgsql
sql_query_pre = ) + SQL_FUNCTIONS['postgresql']['stored_procedures'].values.join(' ') + %(
  )
}
    
  ADAPTER = ActiveRecord::Base.connection.instance_variable_get("@config")[:adapter] rescue 'mysql'
  
  # Install the stored procedures
  SQL_FUNCTIONS[ADAPTER]['stored_procedures'].each do |key, value|
    ActiveRecord::Base.connection.execute(value)
  end
  
  # Logger.
  def self.say msg
    if with_rake
      puts msg[0..0].upcase + msg[1..-1]
    else
      msg = "** ultrasphinx: #{msg}"
      if defined? RAILS_DEFAULT_LOGGER
        RAILS_DEFAULT_LOGGER.warn msg
      else
        STDERR.puts msg
      end
    end
    nil
  end
  
  # Configuration file parser.
  def self.options_for(heading, path)
    section = open(path).read[/^#{heading.gsub('/', '__')}\s*?\{(.*?)\}/m, 1]    
    
    unless section
      Ultrasphinx.say "warning; heading #{heading} not found in #{path}; it may be corrupted. "
      {}
    else      
      options = section.split("\n").map do |line|
        line =~ /\s*(.*?)\s*=\s*([^\#]*)/
        $1 ? [$1, $2.strip] : []
      end      
      Hash[*options.flatten] 
    end
    
  end

  # Introspect on the existing generated conf files
  INDEXER_SETTINGS = options_for('indexer', BASE_PATH)
  CLIENT_SETTINGS = options_for('client', BASE_PATH)
  DAEMON_SETTINGS = options_for('searchd', BASE_PATH)
  SOURCE_SETTINGS = options_for('source', BASE_PATH)
  INDEX_SETTINGS = options_for('index', BASE_PATH)
  
  # Make sure there's a trailing slash
  INDEX_SETTINGS['path'] = INDEX_SETTINGS['path'].chomp("/") + "/" 
  
  DICTIONARY = CLIENT_SETTINGS['dictionary_name'] || 'ap'  
  raise ConfigurationError, "Aspell does not support dictionary names longer than two letters" if DICTIONARY.size > 2

  STOPWORDS_PATH = "#{Ultrasphinx::INDEX_SETTINGS['path']}/#{DICTIONARY}-stopwords.txt"

  MODEL_CONFIGURATION = {}     

  # Complain if the database names go out of sync.
  def self.verify_database_name
    if File.exist? CONF_PATH
      begin
        if options_for(
          "source #{MODEL_CONFIGURATION.keys.first.tableize}", 
          CONF_PATH
        )['sql_db'] != ActiveRecord::Base.connection.instance_variable_get("@config")[:database]
          say "warning; configured database name is out-of-date"
          say "please run 'rake ultrasphinx:configure'"
        end 
      rescue Object
      end
    end
  end
        
end
