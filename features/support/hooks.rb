require "cucumber/rspec/doubles"
require "cucumber/timecop"
require "email_spec/cucumber"

Before do
  # Create default settings if necessary, since the database is truncated
  # after every test.
  #
  # Enable our experimental caching, skipping validations which require
  # setting an admin as the last updater.
  AdminSetting.default.update_attribute(:enable_test_caching, true)

  # Create default language and locale.
  Locale.default

  # Assume all spam checks pass by default.
  allow(Akismetor).to receive(:spam?).and_return(false)

  # Reset the current user:
  User.current_user = nil

  # Clear Memcached
  Rails.cache.clear

  # Remove old tag feeds
  page_cache_dir = Rails.root.join("public/test_cache")
  FileUtils.remove_dir(page_cache_dir, true) if Dir.exist?(page_cache_dir)

  # Clear Redis
  REDIS_AUTOCOMPLETE.flushall
  REDIS_GENERAL.flushall
  REDIS_HITS.flushall
  REDIS_KUDOS.flushall
  REDIS_RESQUE.flushall
  REDIS_ROLLOUT.flushall

  Indexer.all.map(&:prepare_for_testing)
end

After do
  Indexer.all.map(&:delete_index)
end

@javascript = false
Before "@javascript" do
  @javascript = true
end

Before "@disable_caching" do
  ActionController::Base.perform_caching = false
end

After "@disable_caching" do
  ActionController::Base.perform_caching = true
end
