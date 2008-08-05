require 'rubygems'
gem 'activerecord'
require 'active_record'

db_config_file = File.join(File.dirname(__FILE__) + '/../../config/database.yml')
ActiveRecord::Base.configurations = YAML.load_file(db_config_file)
ActiveRecord::Base.establish_connection('streamlined_unittest')