Before do
  # Reset the current user:
  User.current_user = nil

  # Clear Memcached
  Rails.cache.clear

  # Remove old tag feeds
  page_cache_dir = Rails.root.join("public", "test_cache")
  if Dir.exist?(page_cache_dir)
    FileUtils.remove_dir(page_cache_dir, true)
  end

  # Clear Redis
  REDIS_GENERAL.flushall
  REDIS_KUDOS.flushall
  REDIS_RESQUE.flushall
  REDIS_ROLLOUT.flushall
  REDIS_AUTOCOMPLETE.flushall

  step %{all search indexes are completely regenerated}
end
