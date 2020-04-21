class StatCounter < ApplicationRecord
  belongs_to :work

  after_commit :enqueue_to_index, on: :update

  def enqueue_to_index
    IndexQueue.enqueue(self, :stats)
  end

  # Specify the indexer that should be used for this class
  def indexers
    [StatCounterIndexer]
  end

  ###############################################
  ##### MOVING DATA INTO THE DATABASE
  ###############################################

  # Update stat counters and search indexes for works with new kudos, comments, or bookmarks.
  def self.stats_to_database
    work_ids = REDIS_GENERAL.smembers('works_to_update_stats').map{ |id| id.to_i }

    Work.where(id: work_ids).find_each do |work|
      work.update_stat_counter
      REDIS_GENERAL.srem('works_to_update_stats', work.id)
    end
  end

  ####################
  # SCHEDULED JOBS
  ####################

  def self.perform(method, *args)
    send(method, *args)
  end
end
