class AsyncIndexer
  REDIS = REDIS_GENERAL

  ####################
  # CLASS METHODS
  ####################

  def self.perform(name)
    # TODO: Keep the method so we can still run queued jobs from previous
    # versions. However, tests should no longer depend on it.
    #
    # Remove in a future version, once all old jobs have been retried or
    # cleared.
    raise "Avoid using AsyncIndexer.perform in tests" if Rails.env.test?

    indexer = name.split(":").first.constantize
    ids = REDIS.smembers(name)

    return if ids.empty?

    batch = indexer.new(ids).index_documents
    IndexSweeper.new(batch, indexer).process_batch
    REDIS.del(name)
  end

  # Get the appropriate indexers for the class and pass the ids off to them
  # This method is only called internally and klass is not a user-supplied value
  def self.index(klass, ids, priority)
    if klass.to_s =~ /Indexer/
      indexers = [klass]
    else
      klass = klass.constantize if klass.respond_to?(:constantize)
      indexers = klass.new.indexers
    end
    indexers.each do |indexer|
      self.new(indexer, priority).enqueue_ids(ids)
    end
  end

  ####################
  # INSTANCE METHODS
  ####################

  attr_reader :indexer, :priority

  # Just standardizing priority/queue names
  def initialize(indexer, priority)
    @indexer = indexer
    @priority = case priority.to_s
                when "main"
                  "high"
                when "background"
                  "low"
                else
                  priority
                end
  end

  def enqueue_ids(ids)
    name = "#{indexer}:#{ids.first}:#{Time.now.to_i}"
    REDIS.sadd(name, ids)
    AsyncIndexerJob.set(queue: queue).perform_later(name)
  end

  def queue
    "reindex_#{priority}"
  end
end
