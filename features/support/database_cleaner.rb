begin
  require 'database_cleaner'
  require 'database_cleaner/cucumber'

  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

# Default tests, use transaction strategy (faste)
Before('~@no-transaction') do
  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.start
end

After('~@no-transaction') do
  DatabaseCleaner.clean
end

# Here we force the truncation strategy, when we need to test things that
# happens on after_commit hooks (like Devise emails)
Before('@no-transaction') do
  DatabaseCleaner.strategy = :truncation, {
    except: %w(admin_settings languages locales schema_migrations)
  }
  DatabaseCleaner.start
end

After('@no-transaction') do
  DatabaseCleaner.clean
  DatabaseCleaner.strategy = :transaction
end
