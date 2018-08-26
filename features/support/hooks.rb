Before do
  # Clear Memcached
  Rails.cache.clear

  # Clear Redis
  REDIS_GENERAL.flushall
  REDIS_KUDOS.flushall
  REDIS_RESQUE.flushall
  REDIS_ROLLOUT.flushall
  REDIS_AUTOCOMPLETE.flushall

  # ES UPGRADE TRANSITION #
  # Remove rollout activations
  $rollout.activate :start_new_indexing
  $rollout.activate :stop_old_indexing
  $rollout.activate :use_new_search

  step %{all search indexes are completely regenerated}
end
