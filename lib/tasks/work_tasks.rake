namespace :work do
  desc "Purge drafts created more than a week ago"
  task(:purge_old_drafts => :environment) do
     count = Work.purge_old_drafts
     puts "Unposted works (#{count}) created more than one week ago have been purged"
  end

  desc "create missing hit counters"
  task(:missing_hit_counters => :environment) do
    Work.find_each do |work|
      counter = work.hit_counter
      unless counter
        counter = HitCounter.create(:work=>work, :hit_count => 1)
      end
    end
  end

  desc "update database hit counters from redis"
  task(:update_hit_counters => :environment) do
    work_ids = $redis.smembers("Work:new_hits").map{|id| id.to_i}
    found_works = []
    HitCounter.find_each(:conditions => ["work_id IN (?)", work_ids]) do |hit_counter|
      hit_counter.update_from_redis
      $redis.srem("Work:new_hits", hit_counter.work_id)
      found_works << hit_counter.work_id
    end
    # Create hit counters for works that don't have them yet
    (work_ids - found_works).each do |work_id|
      hit_counter = HitCounter.create(:work_id => work_id, :hit_count => HitCounter.redis_hits_for_work(work_id))
      $redis.srem("Work:new_hits", hit_counter.work_id)
    end
  end
end
