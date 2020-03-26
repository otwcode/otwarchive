require 'cucumber/rspec/doubles'
require 'cucumber/timecop'
require 'email_spec/cucumber'

Before do
  settings = AdminSetting.new(invite_from_queue_enabled: ArchiveConfig.INVITE_FROM_QUEUE_ENABLED,
          invite_from_queue_number: ArchiveConfig.INVITE_FROM_QUEUE_NUMBER,
          invite_from_queue_frequency: ArchiveConfig.INVITE_FROM_QUEUE_FREQUENCY,
          account_creation_enabled: ArchiveConfig.ACCOUNT_CREATION_ENABLED,
          days_to_purge_unactivated: ArchiveConfig.DAYS_TO_PURGE_UNACTIVATED)
  settings.save(validate: false)

  language = Language.find_or_create_by(short: "en", name: "English")
  Locale.set_base_locale(iso: "en", name: "English (US)", language_id: language.id)

  # Assume all spam checks pass by default.
  allow(Akismetor).to receive(:spam?).and_return(false)

  # Reset the current user:
  User.current_user = nil

  # Clear Memcached
  Rails.cache.clear

  # Clear Redis
  REDIS_GENERAL.flushall
  REDIS_KUDOS.flushall
  REDIS_RESQUE.flushall
  REDIS_ROLLOUT.flushall
  REDIS_AUTOCOMPLETE.flushall

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
