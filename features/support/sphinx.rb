# require 'cucumber/thinking_sphinx/external_world'
# Cucumber::ThinkingSphinx::ExternalWorld.new

require 'database_cleaner'
DatabaseCleaner.strategy = :truncation
 
Before('@no-txn') do
  DatabaseCleaner.start
end

After('@no-txn') do
  DatabaseCleaner.clean
end

