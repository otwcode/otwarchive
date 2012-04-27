class HitCounter < ActiveRecord::Base
  include LogfileReader
  include WorkStats
  
  belongs_to :work

  after_create :init_redis  
  def init_redis
    $redis.set(redis_stat_key(:hit_count), 0)
    $redis.set(redis_stat_key(:download_count), 0)
  end

  ###############################################
  ##### MOVING DATA INTO THE DATABASE
  ###############################################

  # Persist the hit counts to database
  def self.hits_to_database
    # persist from redis to db
    work_ids = $redis.smembers(WORKS_TO_UPDATE_KEY).map{|id| id.to_i}
    found_works = []

    HitCounter.find_each(:conditions => ["work_id IN (?)", work_ids]) do |hit_counter|
      redis_hits = get_stat(:hit_count, hit_counter.work_id)
      if redis_hits > hit_counter.hit_count
        hit_counter.update_attribute(:hit_count, redis_hits)
      else
        Rails.logger.debug "The redis hit count for work id: #{hit_counter.work_id} was #{redis_hits}. redis has been updated with the database value of #{hit_counter.hit_count}"
        set_stat(:hit_count, hit_counter.work_id, hit_counter.hit_count)
      end
      $redis.srem(WORKS_TO_UPDATE_KEY, hit_counter.work_id)
      found_works << hit_counter.work_id
    end
    
    # Create hit counters for works that don't have them yet
    (work_ids - found_works).each do |work_id|
      hit_counter = HitCounter.create(:work_id => work_id, :hit_count => get_stat(:hit_count, hit_counter.work_id))
      $redis.srem(WORKS_TO_UPDATE_KEY, hit_counter.work_id)
    end
  end


  # Move download counts and referers from logs to database
  def self.logs_to_database
    start_date = AdminSetting.stats_updated_at
    
    # downloads since the start date
    stats = get_work_statistic_from_logs(:download_count, start_date)
    stats.each_pair do |work_id, new_count|
      # add the count to the hit counter
      hc = HitCounter.find_or_initialize_by_work_id(:work_id => work_id)
      hc.download_count += new_count || 0
      hc.save
      # update redis to current value
      set_stat(:download_count, work_id, hc.download_count)
    end

    # referers
    stats = get_work_statistic_from_logs(:links, start_date)
    stats.each_pair do |work_id, referers|
      # group referers by url and pass count
      # Let WorkLink determine whether url valid, etc
      referers.group_by {|referer| referer}.each_pair {|referer, referers| WorkLink.create_or_increment(work_id, referer, referers.count)}      
    end
    
    AdminSetting.set_stats_updated_at(Time.now)
  end



end
