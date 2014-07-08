namespace :reindex do

 desc "Reindex bookmarks"
 task :bookmarks => :environment  do
  time=ENV['TIME_PERIOD'] || 'NOW() - INTERVAL 1 DAY' 
  display_feedback=(ENV['FEEDBACK'] || 'FALSE') == 'TRUE'
  index=0
  Bookmark.joins('JOIN works ON works.id = bookmarks.bookmarkable_id').where(" bookmarks.bookmarkable_type = 'Work' AND works.revised_at > #{time} ").find_each { 
    |b|
    if display_feedback 
     index += 1 
     if index % 100 == 0
	puts index 
     end
    end
    b.update_index }
 end 

end
