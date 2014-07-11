namespace :reindex do

 desc "Reindex bookmarks"
 task :bookmarks => :environment  do
  time=ENV['TIME_PERIOD'] || 'NOW() - INTERVAL 1 DAY' 
  index=0
  Bookmark.joins('JOIN works ON works.id = bookmarks.bookmarkable_id').where(" bookmarks.bookmarkable_type = 'Work' AND works.revised_at > #{time} ").find_each { 
    |b|
    RedisSearchIndexQueue.queue_bookmark(b)
   }
 end 

end
