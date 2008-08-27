module BookmarksHelper
  
  # Generates a draggable, pop-up div which contains the bookmark form 
  def bookmark_link(bookmarkable)
    if logged_in?
      if bookmarkable.class == Work
        fallback = new_work_bookmark_path(bookmarkable)
        text = 'Bookmark this story'.t
      elsif bookmarkable.class == ExternalWork
        fallback = bookmarks_path # more options if necessary
        text = 'Add a new bookmark'.t
      end
      link_to_remote text, {:url => fallback, :method => :get}, :href => fallback 
    end
  end
  
end
