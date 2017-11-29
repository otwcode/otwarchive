class AsyncIndexer

  REDIS = REDIS_GENERAL

  ####################
  # CLASS METHODS
  ####################

  def self.perform(name)
    Rails.logger.info "Blueshirt: Logging use of constantize class self.perform #{name.split(":").first}"
    indexer = name.split(":").first.constantize
    ids = REDIS.smembers(name)
    indexer.new(ids).index_documents
    REDIS.del(name)
  end

  # For the new search code, the indexing is handled
  # by the indexer classes, so make sure we have the right names
  def self.index(klass, ids, priority)
    unless klass.to_s =~ /Indexer/
      klass = "#{klass}Indexer"
    end
    self.new(klass, priority).enqueue_ids(ids)
  end

  ####################
  # INSTANCE METHODS
  ####################

  attr_reader :indexer, :priority

  # Just standardizing priority/queue names
  def initialize(indexer, priority)
    @indexer = indexer
    @priority = case priority.to_s
                when 'main'
                  'high'
                when 'background'
                  'low'
                else
                  priority
                end
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
