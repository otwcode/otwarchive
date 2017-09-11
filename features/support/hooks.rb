Before do
  # Reset Elasticsearch - TIRE
  # Work.tire.index.delete
  # Work.create_elasticsearch_index

  # Bookmark.tire.index.delete
  # Bookmark.create_elasticsearch_index
  # Bookmark.import

  # Tag.tire.index.delete
  # Tag.create_elasticsearch_index

  # Pseud.tire.index.delete
  # Pseud.create_elasticsearch_index

  # Reset Elasticsearch

  [Work, Bookmark, Pseud, Tag].each do |klass|
    if $elasticsearch.indices.exists? index: "ao3_test_#{klass.to_s.downcase}s"
      $elasticsearch.indices.delete index: "ao3_test_#{klass.to_s.downcase}s"
    end

    "#{klass}Indexer".constantize.create_index

    indexer = "#{klass}Indexer".constantize.new(klass.all.pluck(:id))
    indexer.index_documents rescue nil
  end

  # Clear Memcached
  Rails.cache.clear

  # Clear Redis
  REDIS_GENERAL.flushall
  REDIS_KUDOS.flushall
  REDIS_RESQUE.flushall
  REDIS_ROLLOUT.flushall
end
