# An abstract subclass of the RedisSetJob class that adapts the class to handle
# hashes instead of sets.
class RedisHashJob < RedisSetJob
  # Add items to be processed when this job runs:
  def add_to_job(batch)
    redis.mapped_hmset(key, batch)
  end

  # Use hscan to iterate through the hash, and hdel to remove:
  def self.scan_and_remove(redis, key, batch_size:)
    scan_hash_in_batches(redis, key, batch_size: batch_size) do |batch|
      yield batch
      redis.hdel(key, batch.keys)
    end
  end
end
