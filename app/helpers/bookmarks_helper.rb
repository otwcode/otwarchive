module BookmarksHelper
  
  # Generates a draggable, pop-up div which contains the bookmark form 
  def bookmark_link(bookmarkable)
    if logged_in?
      if bookmarkable.class == Chapter
        bookmarkable = bookmarkable.work
      end
      
      if bookmarkable.class == Work
        fallback = new_work_bookmark_path(bookmarkable)
        text = 'Bookmark this story'
      elsif bookmarkable.class == ExternalWork
        fallback = bookmarks_path # more options if necessary
        text = 'Add a new bookmark'
      end
      
      # NOTE: the 'existing' check can't work the same way when bookmarks are owned by pseud
      # Check to see if we already have a bookmark to this object
      #existing = Bookmark.find(:first, 
      #                         :conditions => ["user_id = ? AND 
      #                                         bookmarkable_type = ? AND 
      #                                         bookmarkable_id = ?", 
      #                                         current_user.id, bookmarkable.class.name.to_s, bookmarkable.id])
      existing = nil
      if existing.nil?                                         
        link_to_remote text, {:url => fallback, :method => :get}, :href => fallback
      else
        # eventually we want to add the option here to remove the existing bookmark
        # Enigel Dec 10 08 - adding an edit link for now
        link_to "Edit bookmark", edit_bookmark_path(existing)
      end
    end
  end
  
end
