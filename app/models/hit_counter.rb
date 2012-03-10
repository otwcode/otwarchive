class HitCounter < ActiveRecord::Base
  belongs_to :work
  
  def self.redis_key_for_work(work_id, sym)
    "work:#{work_id}:#{sym}"
  end
  
  def self.redis_hits_for_work(work_id)
    $redis.get(self.redis_key_for_work(work_id, :hit_count)).to_i
  end
  
  def update_from_redis
    if redis_hits > hit_count
      HitCounter.update_all("hit_count = #{redis_hits}", "id = #{id}")
    else
      puts "The redis hit count for work id: #{work_id} was #{redis_hits}. redis has been updated with the database value of #{hit_count}"
      $redis.set(redis_key(:hit_count), hit_count)
    end
  end
  
  def redis_hits
    $redis.get(self.redis_key(:hit_count)).to_i
  end
  
  def redis_key(sym)
    HitCounter.redis_key_for_work(self.work_id, sym)
  end

end
