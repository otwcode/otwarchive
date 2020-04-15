Before do
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
