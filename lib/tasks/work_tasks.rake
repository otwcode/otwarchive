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
    $redis.smembers("Work:new_hits").each do |work_id_str|
      $redis.srem("Work:new_hits", work_id_str)
      work = Work.find_by_id(work_id_str.to_i)
      if work
        work.create_hit_counter unless work.hit_counter
        if work.hits < work.database_hits
          puts "The redis hit count for work id: #{work_id_str} was fewer than the database hit count. redis has been updated with the database value"
          $redis.set(work.redis_key(:hit_count), work.database_hits)
        else
          # puts "Work #{work_id_str} hit count updated from #{work.database_hits} to #{work.hits}"
          work.hit_counter.update_attribute(:hit_count, work.hits)
        end
      else
        puts "Work #{work_id_str} no longer exists"
      end
    end
  end
end
