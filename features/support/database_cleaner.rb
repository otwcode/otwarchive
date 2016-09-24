begin
  require 'database_cleaner'
  require 'database_cleaner/cucumber'

rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Before do
  DatabaseCleaner.strategy = :transaction 
  DatabaseCleaner.start if ENV["DIRTYDB"].nil?
end

After do
  DatabaseCleaner.clean if ENV["DIRTYDB"].nil?
end
