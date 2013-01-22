# Queue the ids of works and bookmarks to be reindexed in redis, and reindex them only at intervals
# Usage: 
# RedisSearchIndexQueue.queue_work(work) or queue_bookmark(bookmark)
# RedisSearchIndexQueue.queue_works(work_ids)
# RedisSearchIndexQueue.queue_bookmarks(bookmark_ids)
class RedisSearchIndexQueue

  # Reindex an object
  def self.reindex(item, options={})
    if item.is_a?(Work)
      queue_work(item, options)
    elsif item.is_a?(Bookmark)
      queue_bookmark(item)
    end
  end
  
  
  #### WORKS
  
  WORKS_INDEX_KEY = "search_index_works"
  
  def self.queue_works(work_ids, options={})
    queue_ids(WORKS_INDEX_KEY, work_ids)   
    unless options[:without_bookmarks].present? 
      # queue their bookmarks also
      queue_bookmarks(Bookmark.where(:bookmarkable_type => "Work", :bookmarkable_id => work_ids).value_of(:id))
    end
  end    
  
  # queue a work to have its search index updated
  def self.queue_work(work, options={})
    queue_item(WORKS_INDEX_KEY, work)
    unless options[:without_bookmarks].present?
      queue_bookmarks(Bookmark.where(:bookmarkable_type => "Work", :bookmarkable_id => work.id).value_of(:id))
    end
  end
  
  # tell elasticsearch to reindex each work 
  def self.reindex_works
    Work.where(:id => get_ids(WORKS_INDEX_KEY)).find_each do |w|
      # we touch works when reindexing for wrangling changes in order to expire the cache 
      # for those works on index pages, so the filters won't be stale
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
