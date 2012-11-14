# Queue the ids of works and bookmarks to be reindexed in redis, and reindex them only at intervals
# Usage: 
# RedisSearchIndexQueue.queue_work(work) or queue_bookmark(bookmark)
# RedisSearchIndexQueue.queue_works(work_ids)
# RedisSearchIndexQueue.queue_bookmarks(bookmark_ids)
class RedisSearchIndexQueue

  # Reindex an object
  def self.reindex(item)
    if item.is_a?(Work)
      queue_work(item)
    elsif item.is_a?(Bookmark)
      queue_bookmark(item)
    end
  end
  
  
  #### WORKS
  
  WORKS_INDEX_KEY = "search_index_work"
  
  def self.queue_works(work_ids)
    work_ids.each {|id| $redis.sadd(WORKS_INDEX_KEY, id)}
    # queue their bookmarks also
    queue_bookmarks(Bookmark.where(:bookmarkable_type => "Work", :bookmarkable_id => work_ids).value_of(:id))
  end    
  
  # queue a work to have its search index updated
  def self.queue_work(work)
    $redis.sadd(WORKS_INDEX_KEY, work.id)
    queue_bookmarks(Bookmark.where(:bookmarkable_type => "Work", :bookmarkable_id => work.id).value_of(:id))
  end
  
  # update the work and its bookmarks 
  def self.reindex_works
    work_ids, resp = $redis.multi do
      $redis.smembers(WORKS_INDEX_KEY)
      $redis.del(WORKS_INDEX_KEY)
    end
    
    Work.where(:id => work_ids).find_each do |w|
      w.update_index
    end
  end


  #### BOOKMARKS

  BOOKMARKS_INDEX_KEY = "search_index_bookmarks"
  
  def self.queue_bookmark(bookmark)
    $redis.sadd(BOOKMARKS_INDEX_KEY, bookmark.id)
  end
  
  def self.queue_bookmarks(bookmark_ids)
    bookmark_ids.each {|id| $redis.sadd(BOOKMARKS_INDEX_KEY, id)}
  end
    
  # reindex the bookmarks
  def self.reindex_bookmarks
    bookmark_ids, resp = $redis.multi do
      $redis.smembers(BOOKMARKS_INDEX_KEY)
      $redis.del(BOOKMARKS_INDEX_KEY)
    end

    Bookmark.where(:id => bookmark_ids).find_each do |b|
      b.update_index
    end
  end
  
end