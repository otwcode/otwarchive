class AsyncIndexer

  REDIS = REDIS_GENERAL

  ####################
  # CLASS METHODS
  ####################

  def self.perform(name)
    Rails.logger.info "Blueshirt: Logging use of constantize class self.perform #{name.split(":").first}"
    indexer = name.split(":").first.constantize
    ids = REDIS.smembers(name)
    batch = indexer.new(ids).index_documents
    process_batch_failures(batch, indexer)

    REDIS.del(name)
  end

  def self.process_batch_failures(batch, indexer)
    unless REDIS.get("#{indexer}:first_failures")
      REDIS.set("#{indexer}:first_failures", [].to_json)
    end

    unless REDIS.get("#{indexer}:permanent_failures")
      REDIS.set("#{indexer}:permanent_failures", [].to_json)
    end

    if batch["errors"]
      rerun_ids = []

      batch["items"].each do |item|
        obj = item[item.keys.first] # update/delete/index
        next unless obj["error"]

        first_failures = JSON.parse(REDIS.get("#{indexer}:first_failures"))
        permanent_failures = JSON.parse(REDIS.get("#{indexer}:permanent_failures"))

        unless permanent_failures.include?(obj["_id"])
          if first_failures.include?({obj["_id"] => obj["error"]})
            permanent_failures << {obj["_id"] => obj["error"]}
            first_failures.delete({obj["_id"] => obj["error"]})
            REDIS.set("#{indexer}:permanent_failures", permanent_failures.to_json)
          else
            first_failures << {obj["_id"] => obj["error"]}
            REDIS.set("#{indexer}:first_failures", first_failures.to_json)
            rerun_ids << obj["_id"]
          end
        end
      end

      new(indexer, "failures").enqueue_ids(rerun_ids) unless rerun_ids.empty?
    end
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
