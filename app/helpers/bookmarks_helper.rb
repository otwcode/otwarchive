module BookmarksHelper
  
  # Starting with something basic, hoping to get much snazzier!
  def bookmark_link(bookmarkable)
    link_to "Bookmark".t, new_work_bookmark_path(bookmarkable) if bookmarkable.class == Work
  end
  
end
