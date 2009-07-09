# This task will reset the db and load in clean test data using the fixtures
# Usage: rake load_test_data
namespace :db do

  desc "Raise an error unless the RAILS_ENV is development"
  task :development_environment_only do
    raise "ZOMG NOT IN PRODUCTION!" unless RAILS_ENV == 'development'
  end
  
  desc "Reset and then seed the development database with test data from the fixtures"
  task :seed => [:environment, :development_environment_only, :reset, 'fixtures:load', 'Tag:reset_filters', 'Tag:reset_filter_counts'] 
end
