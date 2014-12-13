class StatCounter < ActiveRecord::Base
  include LogfileReader
  include WorkStats
  
  belongs_to :work

  after_create :init_redis  
  def init_redis
    REDIS_GENERAL.set(redis_stat_key(:hit_count), 0)
    REDIS_GENERAL.set(redis_stat_key(:download_count), 0)
  end

  after_commit :enqueue_to_index, on: :update

  def enqueue_to_index
    IndexQueue.enqueue(self, :stats)
  end

  ###############################################
  ##### MOVING DATA INTO THE DATABASE
  ###############################################

  # Persist the hit counts to database
  def self.hits_to_database
    # persist from redis to db
    work_ids = REDIS_GENERAL.smembers(WORKS_TO_UPDATE_KEY).map{|id| id.to_i}
    found_works = []

    StatCounter.find_each(:conditions => ["work_id IN (?)", work_ids]) do |stat_counter|
      redis_hits = get_stat(:hit_count, stat_counter.work_id)
      if redis_hits > stat_counter.hit_count
        stat_counter.update_attribute(:hit_count, redis_hits)
      else
        Rails.logger.debug "The redis hit count for work id: #{stat_counter.work_id} was #{redis_hits}. redis has been updated with the database value of #{stat_counter.hit_count}"
        set_stat(:hit_count, stat_counter.work_id, stat_counter.hit_count)
      end
      REDIS_GENERAL.srem(WORKS_TO_UPDATE_KEY, stat_counter.work_id)
      found_works << stat_counter.work_id
    end
    
    # Create hit counters for works that don't have them yet
    (work_ids - found_works).each do |work_id|
      stat_counter = StatCounter.create(:work_id => work_id, :hit_count => get_stat(:hit_count, work_id))
      REDIS_GENERAL.srem(WORKS_TO_UPDATE_KEY, work_id)
    end
    
    # queue the works for reindexing
    # we might have to reduce the frequency of this -- will see!
    # RedisSearchIndexQueue.queue_works(work_ids, without_bookmarks: true)
  end
  
  # Update stat counters and search indexes for works with new kudos, comments, or bookmarks.
  def self.stats_to_database
    work_ids = REDIS_GENERAL.smembers('works_to_update_stats').map{ |id| id.to_i }

    Work.where(id: work_ids).find_each do |work|
      work.update_stat_counter
      REDIS_GENERAL.srem('works_to_update_stats', work.id)
    end
  end

  # Move download counts and referers from logs to database
  def self.logs_to_database
    start_date = AdminSetting.stats_updated_at
    
    # downloads since the start date
    stats = get_work_statistic_from_logs(:download_count, start_date)
    stats.each_pair do |work_id, new_count|
      # add the count to the hit counter
      hc = StatCounter.find_or_initialize_by_work_id(:work_id => work_id)
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
