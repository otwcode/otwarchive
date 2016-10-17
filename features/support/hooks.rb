Before do
  Work.tire.index.delete
  Work.create_elasticsearch_index
  Work.tire.index.refresh

  Bookmark.tire.index.delete
  Bookmark.create_elasticsearch_index
  Bookmark.import

  Tag.tire.index.delete
  Tag.create_elasticsearch_index

  Pseud.tire.index.delete
  Pseud.create_elasticsearch_index

  Rails.cache.clear
end

Before('~@no-txn') do
  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.start
end

Before('@no-txn') do
  DatabaseCleaner.strategy = :truncation, {
    except: %w(admin_settings languages locales)
  }
end

Before('@disable_caching') do
  ActionController::Base.perform_caching = false
end

After('@disable_caching') do
  ActionController::Base.perform_caching = true
end

After do
  DatabaseCleaner.clean
end
