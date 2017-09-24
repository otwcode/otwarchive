Before do
  # Reset Elasticsearch
  Work.tire.index.delete
  Work.create_elasticsearch_index

  Bookmark.tire.index.delete
  Bookmark.create_elasticsearch_index
  Bookmark.import

  Tag.tire.index.delete
  Tag.create_elasticsearch_index

  Pseud.tire.index.delete
  Pseud.create_elasticsearch_index

  # Clear Memcached
  Rails.cache.clear

  # Clear Redis
  REDIS_GENERAL.flushall
  REDIS_KUDOS.flushall
  REDIS_RESQUE.flushall
  REDIS_ROLLOUT.flushall
  REDIS_AUTOCOMPLETE.flushall
end
