%w(can_has_bookmarks has_bookmarks can_create_bookmarks).each do |file|
  require file
end

ActiveRecord::Base.send :include, CanHasBookmarks
