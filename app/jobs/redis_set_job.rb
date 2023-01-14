class RedisSetJob < ApplicationJob
  extend RedisScanning

  def self.redis
    REDIS_GENERAL
  end

  def self.base_key
    raise "Must be implemented in subclass!"
  end

  def self.batch_size
    1000
  end

  def perform(key)
    batch = redis.smembers(key)
    perform_on_batch(batch)
    redis.srem(key, batch)
  end

  def perform_on_batch(batch)
    raise "Must be implemented in subclass!"
  end

  def self.split_jobs(key: base_key)
    scan_set_in_batches(redis, key, batch_size: batch_size) do |batch|
      batch_id = redis.incr("batch:#{base_key}:batch_id")
      batch_key = "batch:#{base_key}:#{batch_id}"
      redis.sadd(batch_key, batch)
      perform_later(batch_key)
      redis.srem(key, batch)
    end
  end

  delegate :redis, to: :class
end
