begin
  require 'database_cleaner'
  require 'database_cleaner/cucumber'

  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end


Before do
  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.start

  # Load Locale fixtures so that Locale.find(1) will always exist
  ActiveRecord::FixtureSet.reset_cache
  fixtures_folder = File.join(Rails.root, 'features', 'fixtures')
  ActiveRecord::FixtureSet.create_fixtures(fixtures_folder, ['locales'])
end

After do
  DatabaseCleaner.clean
end
