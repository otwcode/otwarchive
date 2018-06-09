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
  # Remove rollout activation & unless block
  $rollout.activate :start_new_indexing

  unless elasticsearch_enabled?($elasticsearch)
    $rollout.activate :stop_old_indexing
    $rollout.activate :use_new_search
  end

  step %{all search indexes are completely regenerated}
end

# ES UPGRADE TRANSITION #
# Remove hook
Before '@new-search' do
  $rollout.activate :use_new_search
end
