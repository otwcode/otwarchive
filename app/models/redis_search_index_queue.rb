# Queue the ids of works and bookmarks to be reindexed in resque
# Usage: 
# RedisSearchIndexQueue.queue_work(work) or queue_bookmark(bookmark)
# RedisSearchIndexQueue.queue_works(work_ids)
# RedisSearchIndexQueue.queue_bookmarks(bookmark_ids)
class RedisSearchIndexQueue
  
  # Resque
  
  # This will be called by a worker when a job needs to be processed
  def self.perform(method, *args)
    self.send(method, *args)
  end

  # We can pass this any method that we want to run later.
  def self.async(method, id, options={})
    if options[:priority] == :low
      queue = :reindex_low
    else
      queue = :reindex_high
    end
    Resque::Job.create(queue, RedisSearchIndexQueue, method, id)
  end

  # Reindex an object
  def self.reindex(item, options={})
    if item.is_a?(Work)
      queue_work(item, options)
    elsif item.is_a?(Bookmark)
      queue_bookmark(item, options)
    end
  end
  
  #### WORKS
  
  def self.queue_works(work_ids, options={})
    work_ids.each { |id| async(:run_work_reindex, id, options) }
    unless options[:without_bookmarks].present? 
      # queue their bookmarks also
      queue_bookmarks(Bookmark.where(:bookmarkable_type => "Work", :bookmarkable_id => work_ids).value_of(:id), options)
    end
  end    
  
  # queue a work to have its search index updated
  def self.queue_work(work, options={})
    async(:run_work_reindex, work.id, options)
    unless options[:without_bookmarks].present?
      queue_bookmarks(Bookmark.where(:bookmarkable_type => "Work", :bookmarkable_id => work.id).value_of(:id), options)
    end
  end
  
  def self.run_work_reindex(work_id)
    Work.find(work_id).update_index
  end

  #### BOOKMARKS

  def self.queue_bookmark(bookmark, options={})
    async(:run_bookmark_reindex, bookmark.id, options)
  end
  
  def self.queue_bookmarks(ids, options={})
    ids.each { |id| async(:run_bookmark_reindex, id, options) }
  end

  def self.run_bookmark_reindex(bookmark_id)
    Bookmark.find(bookmark_id).update_index
  end
  
end
