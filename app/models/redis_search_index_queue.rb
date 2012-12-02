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
  
  WORKS_INDEX_KEY = "search_index_works"
  
  def self.queue_works(work_ids)
    queue_ids(WORKS_INDEX_KEY, work_ids)    
    # queue their bookmarks also
    queue_bookmarks(Bookmark.where(:bookmarkable_type => "Work", :bookmarkable_id => work_ids).value_of(:id))
  end    
  
  # queue a work to have its search index updated
  def self.queue_work(work)
    queue_item(WORKS_INDEX_KEY, work)
    queue_bookmarks(Bookmark.where(:bookmarkable_type => "Work", :bookmarkable_id => work.id).value_of(:id))
  end
  
  # tell elasticsearch to reindex each work 
  def self.reindex_works
    Work.where(:id => get_ids(WORKS_INDEX_KEY)).find_each do |w|
      w.touch
      w.update_index
    end
  end


  #### BOOKMARKS

  BOOKMARKS_INDEX_KEY = "search_index_bookmarks"
  
  def self.queue_bookmark(bookmark)
    queue_item(BOOKMARKS_INDEX_KEY, bookmark)
  end
  
  def self.queue_bookmarks(ids)
    queue_ids(BOOKMARKS_INDEX_KEY, ids)
  end
    
  # reindex the bookmarks
  def self.reindex_bookmarks
    Bookmark.where(:id => get_ids(BOOKMARKS_INDEX_KEY)).find_each do |b|
      b.update_index
    end
  end
  

  #### SHARED
  
  # store id into redis set
  def self.queue_item(key, item)
    $redis.sadd(key, item.id)
  end
  
  # store ids into a redis set (duplicates will be removed)
  def self.queue_ids(key, ids)
    ids.each {|id| $redis.sadd(key, id)}
  end
    
  # get the ids out of the set and empty it (atomically)
  def self.get_ids(key)
    ids, resp = $redis.multi do
      $redis.smembers(key)
      $redis.del(key)
    end
    return ids
  end
    
  
  
end