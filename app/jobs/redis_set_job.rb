# An abstract class designed to make it easier to queue up jobs with a Redis
# set, then split those jobs into chunks to process them.
class RedisSetJob < ApplicationJob
  extend RedisScanning

  # For any subclasses of this job, we want to try to recover from deadlocks
  # and lock wait timeouts. The 5 minute delay should hopefully be long enough
  # that whatever transaction caused the deadlock will be over with by the time
  # we retry.
  retry_on ActiveRecord::Deadlocked, attempts: 10, wait: 5.minutes
  retry_on ActiveRecord::LockWaitTimeout, attempts: 10, wait: 5.minutes

  # The redis server used for this job.
  def self.redis
    REDIS_GENERAL
  end

  # The default key for the Redis set that we want to process. Used by the
  # RedisJobSpawner.
  def self.base_key
    raise "Must be implemented in subclass!"
  end

  # The number of items we'd like to have in a single job.
  def self.job_size
    1000
  end

  # The number of items to process in a single call to perform_on_batch. This
  # should be smaller than job_size, otherwise it'll just use job_size for the
  # batch size.
  def self.batch_size
    100
  end

  def perform(*args, **kwargs)
    scan_and_remove(redis, key, batch_size: batch_size) do |batch|
      perform_on_batch(batch, *args, **kwargs)
    end
  end

  # This is where the real work happens:
  def perform_on_batch(*)
    raise "Must be implemented in subclass!"
  end

  # The Redis key used to store the objects that this job needs to process:
  def key
    @key ||= "job:#{self.class.name.underscore}:batch:#{job_id}"
  end

  # Add items to be processed when this job runs:
  def add_to_job(batch)
    redis.sadd(key, batch)
  end

  # Use sscan to iterate through the set, and srem to remove:
  def self.scan_and_remove(redis, key, batch_size:)
    scan_set_in_batches(redis, key, batch_size: batch_size) do |batch|
      yield batch
      redis.srem(key, batch)
    end
  end

  # Use scan_and_remove to divide the queue into batches, and create a job for
  # each batch:
  def self.spawn_jobs(*args, redis: self.redis, key: self.base_key, **kwargs)
    scan_and_remove(redis, key, batch_size: job_size) do |batch|
      job = new(*args, **kwargs)
      job.add_to_job(batch)
      job.enqueue
    end
  end

  delegate :redis, :job_size, :batch_size, :scan_and_remove, to: :class
end
