Before do
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

AfterStep do |scenario|
  return if page.blank?
  page.has_no_text?("Work")
end
