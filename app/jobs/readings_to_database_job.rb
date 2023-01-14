class ReadingsToDatabaseJob < ApplicationJob
  include RedisScanning

  retry_on ActiveRecord::Deadlocked, attempts: 10

  def perform(key)
    scan_set_in_batches(REDIS_GENERAL, key, batch_size: batch_size) do |batch|
      process_batch(batch)
      remove_readings(key, batch)
    end
  end

  private

  def batch_size
    ArchiveConfig.READING_BATCHSIZE
  end

  # Takes a batch of reading retrieved from redis, and calls the method
  # Reading.reading_object on each one.
  def process_batch(batch)
    # Each item in the batch is an array of arguments encoded as a JSON:
    parsed_batch = batch.map do |json|
      ActiveSupport::JSON.decode(json)
    end

    # Sort to try to reduce deadlocks.
    #
    # The first argument is user_id, the third argument is work_id:
    sorted_batch = parsed_batch.sort_by do |args|
      [args.first.to_i, args.third.to_i]
    end

    # Finally, start a transaction and call Reading.reading_object to write the
    # information to the database:
    Reading.transaction do
      sorted_batch.each do |args|
        Reading.reading_object(*args)
      end
    end
  end

  # Remove the batch from Redis:
  def remove_readings(key, batch)
    REDIS_GENERAL.srem(key, batch) unless batch.empty?
  end
end
