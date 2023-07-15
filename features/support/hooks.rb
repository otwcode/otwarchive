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

  # Clears used values for all generators.
  Faker::UniqueGenerator.clear

  # Reset global locale setting.
  I18n.locale = I18n.default_locale

  # Assume all spam checks pass by default.
  allow(Akismetor).to receive(:spam?).and_return(false)

  # Don't authenticate for Zoho.
  allow_any_instance_of(ZohoAuthClient).to receive(:access_token)

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

  Capybara.app_host = CAPYBARA_URL
end

Before "not @javascript" do
  Capybara.app_host = "http://www.example.com"
end

Before "@disable_caching" do
  ActionController::Base.perform_caching = false
end

After "@disable_caching" do
  ActionController::Base.perform_caching = true
end

Before "@set-default-skin" do
  # Create a default skin:
  AdminSetting.current.update_attribute(:default_skin, Skin.default)
end

Before "@load-default-skin" do
  # Load the site skin and make it the default:
  Skin.load_site_css
  Skin.set_default_to_current_version
  AdminSetting.current.update_attribute(:default_skin, Skin.default)
end
