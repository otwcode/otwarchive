require 'cucumber/rspec/doubles'
require 'cucumber/timecop'
require 'email_spec/cucumber'

Before do
  # Create default language and locale.
  Locale.default

  # Assume all spam checks pass by default.
  allow(Akismetor).to receive(:spam?).and_return(false)

  # Reset the current user:
  User.current_user = nil

  # Clear Memcached
  Rails.cache.clear

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
