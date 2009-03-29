require 'test/unit'
require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'action_pack'
require 'action_controller'
require 'action_controller/test_process'
require 'action_mailer'
require 'active_record'
require 'active_record/fixtures'

require 'pp'

require File.dirname(__FILE__) + '/../init'
RAILS_ENV  = "test" unless defined? RAILS_ENV

# Set up an ActiveRecord connection to sqlite db for testing
# 
# Borrowed from setup in classic_pagination plugin

plugin_root = File.join(File.dirname(__FILE__), '..')
# is the plugin installed in an application?
app_root = plugin_root + '/../../..'

if File.directory? app_root + '/config'
  ENV['RAILS_ENV'] = 'test'
  require File.expand_path(app_root + '/config/boot')
end

# Define the connector
class ActiveRecordTestConnector
  cattr_accessor :able_to_connect
  cattr_accessor :connected

  # Set our defaults
  self.connected = false
  self.able_to_connect = true

  class << self
    def setup
      unless self.connected || !self.able_to_connect
        setup_connection
        load_schema
        self.connected = true
      end
    rescue Exception => e  # errors from ActiveRecord setup
      $stderr.puts "\nSkipping ActiveRecord assertion tests: #{e}"
      self.able_to_connect = false
    end

    private

    def setup_connection
      if Object.const_defined?(:ActiveRecord)
        defaults = { :database => ':memory:' }
        begin
          options = defaults.merge :adapter => 'sqlite3', :timeout => 500
          ActiveRecord::Base.establish_connection(options)
          ActiveRecord::Base.configurations = { 'sqlite3_ar_integration' => options }
          ActiveRecord::Base.connection
        rescue Exception  # errors from establishing a connection
          $stderr.puts 'SQLite 3 unavailable; trying SQLite 2.'
          options = defaults.merge :adapter => 'sqlite'
          ActiveRecord::Base.establish_connection(options)
          ActiveRecord::Base.configurations = { 'sqlite2_ar_integration' => options }
          ActiveRecord::Base.connection
        end

        Object.send(:const_set, :QUOTED_TYPE, ActiveRecord::Base.connection.quote_column_name('type')) unless Object.const_defined?(:QUOTED_TYPE)
      else
        raise "Can't setup connection since ActiveRecord isn't loaded."
      end
    end

    # Loads the schema.rb 
    def load_schema
      # Silence the output of creating the db
      silence_stream(STDOUT) do
        Dir.glob(File.dirname(__FILE__) + "/fixtures/schema.rb").each {|f| require f}
      end
    end
  end
end

ActiveRecordTestConnector.setup
