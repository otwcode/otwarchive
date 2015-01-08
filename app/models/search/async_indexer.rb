class AsyncIndexer

  REDIS = REDIS_GENERAL

  ####################
  # CLASS METHODS
  ####################

  def self.perform(name)
    indexer = name.split(":").first.constantize
    ids = REDIS.smembers(name)
    indexer.new(ids).index_documents
    REDIS.del(name)
  end

  ####################
  # INSTANCE METHODS
  ####################

  attr_reader :indexer, :priority

  def initialize(indexer, priority)
    @indexer = indexer
    @priority = priority
  end

  def enqueue_ids(ids)
    name = "#{indexer}:#{ids.first}:#{Time.now.to_i}"
    REDIS.sadd(name, ids)
    Resque::Job.create(queue, self.class, name)
  end

  def queue
    "reindex_#{priority}"
  end

end