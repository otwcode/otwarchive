module BookmarksHelper
  
  # Generates a draggable, pop-up div which contains the bookmark form 
  def bookmark_link(bookmarkable)
    if logged_in?
      if bookmarkable.class == Work
        fallback = new_work_bookmark_path(bookmarkable)
        text = 'Bookmark'
      elsif bookmarkable.class == ExternalWork
        fallback = bookmarks_path # more options if necessary
        text = 'Add a new bookmark'
      end
      link_to_remote text.t, {:url => fallback, :method => :get}, :href => fallback 
    end
  end
  
end
