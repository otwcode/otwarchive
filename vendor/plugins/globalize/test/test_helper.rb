ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + '/../../../../config/environment')
require 'logger'
require 'test_help'
require 'stringio'

plugin_path = File.expand_path(File.dirname(__FILE__)+"/../")
config_location = RAILS_ROOT + "/config/database.yml"

config = YAML::load(ERB.new(IO.read(config_location)).result)
log_file = plugin_path + "/test/log/test.log"
FileUtils.touch(log_file) unless File.exist?(log_file)
ActiveRecord::Base.logger = Logger.new(log_file)
ActiveRecord::Base.establish_connection(config['test'])

schema_file = plugin_path + "/test/db/schema.rb"
load(schema_file) if File.exist?(schema_file)

Test::Unit::TestCase.fixture_path = plugin_path + "/test/fixtures/"

$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)
