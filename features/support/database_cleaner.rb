begin
  require 'database_cleaner'
  require 'database_cleaner/cucumber'

  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.clean

  Around do |_scenario, block|
    DatabaseCleaner.cleaning(&block)
  end
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end
