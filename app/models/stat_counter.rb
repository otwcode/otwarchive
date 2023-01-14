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
    StatCounterJob.split_jobs
  end

  ####################
  # SCHEDULED JOBS
  ####################

  def self.perform(method, *args)
    send(method, *args)
  end
end
