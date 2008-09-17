require 'active_record'
require 'active_record/connection_adapters/mysql_adapter'
begin
  require 'active_record/connection_adapters/postgresql_adapter'
rescue LoadError
  # No postgres?  no prob...
end
require 'yaml'

class SphinxHelper
  attr_accessor :host, :username, :password
  attr_reader   :path
  
  def initialize
    @host     = "localhost"
    @username = "thinking_sphinx"
    @password = ""

    if File.exist?("spec/fixtures/database.yml")
      config    = YAML.load(File.open("spec/fixtures/database.yml"))
      @host     = config["host"]
      @username = config["username"]
      @password = config["password"]
    end
    
    @path = File.expand_path(File.dirname(__FILE__))
  end
  
  def setup_mysql
    ActiveRecord::Base.establish_connection(
      :adapter  => 'mysql',
      :database => 'thinking_sphinx',
      :username => @username,
      :password => @password,
      :host     => @host
    )
    ActiveRecord::Base.logger = Logger.new(File.open("tmp/activerecord.log", "a"))
    
    structure = File.open("spec/fixtures/structure.sql") { |f| f.read.chomp }
    structure.split(';').each { |table|
      ActiveRecord::Base.connection.execute table
    }
    
    File.open("spec/fixtures/data.sql") { |f|
      while line = f.gets
        ActiveRecord::Base.connection.execute line
      end
    }
  end
  
  def setup_sphinx
    @configuration = ThinkingSphinx::Configuration.new
    File.open("spec/fixtures/sphinx/database.yml", "w") do |file|
      YAML.dump({@configuration.environment => {
        :adapter  => 'mysql',
        :host     => @host,
        :database => "thinking_sphinx",
        :username => @username,
        :password => @password
      }}, file)
    end
    FileUtils.mkdir_p(@configuration.searchd_file_path)
    
    @configuration.database_yml_file = "spec/fixtures/sphinx/database.yml"
    @configuration.build
    
    index
  end
  
  def reset
    setup_mysql
  end
    
  def index
    cmd = "indexer --config #{@configuration.config_file} --all"
    cmd << " --rotate" if running?
    `#{cmd}`
  end
  
  def start
    return if running?
    
    cmd = "searchd --config #{@configuration.config_file}"
    `#{cmd}`    

    sleep(1)

    unless running?
      puts "Failed to start searchd daemon. Check #{@configuration.searchd_log_file}."
    end
  end
  
  def stop
    return unless running?
    `kill #{pid}`
  end
  
  def pid
    if File.exists?("#{@configuration.pid_file}")
      `cat #{@configuration.pid_file}`[/\d+/]
    else
      nil
    end
  end

  def running?
    pid && `ps #{pid} | wc -l`.to_i > 1
  end
end
