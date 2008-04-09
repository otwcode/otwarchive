# Rails environment configuration and loading.
ENV["RAILS_ENV"] ||= "test"
dir = File.dirname(__FILE__)
require "#{dir}/../../../../config/environment"

# Database configuration and schema loading. 
dbconfig = YAML::load(IO.read("#{dir}/resources/config/database.yml"))
ActiveRecord::Base.configurations = {'test' => dbconfig[ENV['DB'] || 'sqlite3']}
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
ActiveRecord::Migration.verbose = false
load("#{dir}/resources/schema.rb")

# RSpec configuration.
require 'spec/rails'
Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = "#{dir}/resources/fixtures"
end

# Rails resoure loading (models, controllers, routes).
Dir["#{dir}/resources/**/*.rb"].each do |file|
  require file
end

# Spec helper methods
# --------------------
#
# Return a hash of valid attributes for a certain model.
def valid(model, options={})
  self.send("valid_#{model}").merge(options)
end

# Create a valid model object of the given kind.
def create_valid(model, options={})
  eval("#{model.to_s.camelize}.create(valid_#{model}.merge(options))")
end

# Valid attributes for an authentable user.
def valid_user
  { :login => 'vito',
    :password => 'MakeHimAnOffer',
    :password_confirmation => 'MakeHimAnOffer' }
end

# Match with a pattern against an error objects first member or sole member.
def match_first(errors, pattern)
  if errors.kind_of? Array
    errors.first.should match(pattern)
  else
    errors.should match(pattern)
  end
end
