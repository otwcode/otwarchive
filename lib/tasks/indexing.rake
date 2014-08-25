namespace :reindex do

 desc "Reindex bookmarks"
 task :bookmarks => :environment  do
  time=ENV['TIME_PERIOD'] || 'NOW() - INTERVAL 1 DAY' 
  Bookmark.joins('JOIN works ON works.id = bookmarks.bookmarkable_id').where(" bookmarks.bookmarkable_type = 'Work' AND works.revised_at > #{time} ").find_each { 
    |b|
    RedisSearchIndexQueue.queue_bookmark(b)
   }
 end 

 desc "Reindex works"
 task :works => :environment  do
  time=ENV['TIME_PERIOD'] || 'NOW() - INTERVAL 1 DAY'
  Work.where("works.revised_at >  #{time}").find_each {
    |w|
    RedisSearchIndexQueue.queue_work(w)
   }
 end

 desc "Clear cache works"
 task :works_cache => :environment  do
  time=ENV['TIME_PERIOD'] || 'NOW() - INTERVAL 1 DAY'
  Work.where("works.revised_at >  #{time}").find_each {
    |w|
    w.expire_caches
   }
 end

end
