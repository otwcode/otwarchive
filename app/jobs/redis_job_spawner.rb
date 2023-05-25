# An ActiveJob designed to spawn a bunch of subclasses of RedisSetJob or
# RedisHashJob. Renames the desired redis key to avoid conflicts with other
# code that might be modifying the same set/hash, then calls spawn_jobs on the
# desired job class.
class RedisJobSpawner < ApplicationJob
  def perform(job_name, *args, key: nil, redis: nil, **kwargs)
    job_class = job_name.constantize

    # Read settings from the job class:
    redis ||= job_class.redis
    key ||= job_class.base_key

    # Bail out early if there's nothing to process:
    return unless redis.exists(key)

    # Rename the job to a unique name to avoid conflicts when this is called
    # multiple times in a short period:
    spawn_id = redis.incr("job:#{job_name.underscore}:spawn:id")
    spawn_key = "job:#{job_name.underscore}:spawn:#{spawn_id}"
    redis.rename(key, spawn_key)

    # Tell the job class to handle the spawning.
    job_class.spawn_jobs(*args, redis: redis, key: spawn_key, **kwargs)
  end
end
