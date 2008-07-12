require 'mysql'
require 'erb'
require 'yaml'

class SphinxHelper
  attr_accessor :host, :username, :password
  attr_reader   :path
  
  def initialize
    @host     = "localhost"
    @username = "anonymous"
    @password = ""

    if File.exist?("spec/fixtures/sql/conf.yml")
      config    = YAML.load(File.open("spec/fixtures/sql/conf.yml"))
      @host     = config["host"]
      @username = config["username"]
      @password = config["password"]
    end
    
    @path = File.expand_path(File.dirname(__FILE__))
  end
  
  def setup_mysql
    server = Mysql.new @host, @username, @password

    unless server.list_dbs.include?("riddle_sphinx_spec")
      server.create_db "riddle_sphinx_spec"
    end

    server.query "USE riddle_sphinx_spec;"
    
    structure = File.open("spec/fixtures/sql/structure.sql") { |f| f.read }
    # Block ensures multiple statements can be run
    server.query(structure) { }
    data      = File.open("spec/fixtures/sql/data.sql") { |f|
      while line = f.gets
        server.query line
      end
    }

    server.close
  end
  
  def reset
    setup_mysql
    index
  end
  
  def generate_configuration
    template = File.open("spec/fixtures/sphinx/configuration.erb") { |f| f.read }
    File.open("spec/fixtures/sphinx/spec.conf", "w") { |f|
      f.puts ERB.new(template).result(binding)
    }
  end
  
  def index
    cmd = "indexer --config #{@path}/fixtures/sphinx/spec.conf --all"
    cmd << " --rotate" if running?
    `#{cmd}`
  end
  
  def start
    return if running?

    cmd = "searchd --config #{@path}/fixtures/sphinx/spec.conf"
    `#{cmd}`

    sleep(1)

    unless running?
      puts "Failed to start searchd daemon. Check fixtures/sphinx/searchd.log."
    end
  end
  
  def stop
    return unless running?
    `kill #{pid}`
  end
  
  def pid
    if File.exists?("#{@path}/fixtures/sphinx/searchd.pid")
      `cat #{@path}/fixtures/sphinx/searchd.pid`[/\d+/]
    else
      nil
    end
  end

  def running?
    pid && `ps #{pid} | wc -l`.to_i > 1
  end
end