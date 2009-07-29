module BookmarksHelper
  
  # Generates a draggable, pop-up div which contains the bookmark form 
  def bookmark_link(bookmarkable, blurb=false)
    # blurb=true is passed from the bookmark blurb to generate a save/saved link
    if logged_in?
      if bookmarkable.class == Chapter
        bookmarkable = bookmarkable.work
      end
      
      if bookmarkable.class == Work
        fallback = new_work_bookmark_path(bookmarkable)
        blurb == true ? text = t('save_bookmark', :default => 'Save') : 
        text = t('bookmark', :default => 'Bookmark') 
      elsif bookmarkable.class == ExternalWork
        fallback = bookmarks_path # more options if necessary
        blurb == true ? text = t('save_bookmark', :default => 'Save') :
        text = t('add_new_bookmark', :default => 'Add A New Bookmark')
      end
      # Check to see if the user has an existing bookmark on this object. Note: on work page we eventually want to change this so an 
      # existing bookmark is opened for editing but a new bookmark can be created by selecting a different pseud on the form.
      existing = Bookmark.find(:first, :conditions => ["bookmarkable_type = ? AND bookmarkable_id = ? AND pseud_id IN (?)", bookmarkable.class.name.to_s, bookmarkable.id, current_user.pseuds.collect(&:id)])
      if existing.nil?                                         
        link_to_remote text, {:url => fallback, :method => :get}, :href => fallback
      else
        # eventually we want to add the option here to remove the existing bookmark
        # Enigel Dec 10 08 - adding an edit link for now
        if blurb == true 
          link_to t('saved_bookmark', :default => 'Saved'), bookmark_path(existing) 
        else  
          link_to t('edit_bookmark', :default => "Edit/Add Bookmark"), edit_bookmark_path(existing)
        end      
      end
    end
  end
  
  # tag_bookmarks_path was behaving badly for tags with slashes
  def link_to_tag_bookmarks(tag)
    {:controller => 'bookmarks', :action => 'index', :tag_id => tag}
  end
  
  def link_to_bookmarkable_bookmarks(bookmarkable)
    link_to Bookmark.count_visible_bookmarks(bookmarkable, current_user), eval(bookmarkable.class.to_s.underscore + "_bookmarks_path(bookmarkable)")
  end
  
end
