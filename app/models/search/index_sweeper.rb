class IndexSweeper

  REDIS = AsyncIndexer::REDIS

  def self.async_cleanup(klass, expected_ids, found_ids)
    deleted_ids = expected_ids.map(&:to_i).select { |id| !found_ids.include?(id) }

    if deleted_ids.any?
      AsyncIndexer.index(klass, deleted_ids, "cleanup")
    end
  end

  def initialize(batch, indexer, retries=1)
    @batch = batch
    @indexer = indexer
    @retries = retries

    setup_failure_stores
  end

  def process_batch_failures
    return unless @batch["errors"]

    rerun_ids = []

    @batch["items"].each do |item|
      obj = item[item.keys.first] # update/delete/index
      next unless obj["error"]

      stamp = { obj["_id"] => obj["error"] }

      track_failure_progess = {}
      first_failures = JSON.parse(REDIS.get("#{@indexer}:failures_batch_1"))

      @retries.times do |i|
        failure_num = i+1
        track_failure_progress[failure_num+1] ||= []

        failures = JSON.parse(REDIS.get("#{@indexer}:failures_batch_#{failure_num}"))
        if failures.include?(stamp)
          track_failure_progress[failure_num+1] << stamp
        else
          first_failures << stamp
        end
      end

      REDIS.set("#{@indexer}:failures_batch_1", first_failures)
      REDIS.set("#{@indexer}:permanent_failures", track_failure_progress[@retries+1])
      @retries.times do |i|
        failure_num = i+1
        next if failure_num == 1
        REDIS.set("#{@indexer}:failures_batch_#{failure_num}", track_failure_progress[failure_num])
      end
    end
  end

  private

  def setup_failure_stores
    @retries.times do |i|
      unless REDIS.get("#{@indexer}:failures_batch_#{i+1}")
        REDIS.set("#{@indexer}:failures_batch_#{i+1}", [])
      end
    end

    unless REDIS.get("#{@indexer}:permanent_failures")
      REDIS.set("#{@indexer}:permanent_failures", [])
    end
  end

end
