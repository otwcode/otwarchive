module BookmarksHelper
  
  # Generates a draggable, pop-up div which contains the bookmark form 
  def bookmark_link(bookmarkable)
    if logged_in?
      if bookmarkable.class == Work
        fallback = new_work_bookmark_path(bookmarkable)
        text = "Bookmark"
      elsif bookmarkable.class == ExternalWork
        fallback = bookmarks_path # more options if necessary
        text = "Add a new bookmark"
      end
      link_to_function(text.t, :href => fallback) do |page| 
        page.show 'dynamic-bookmark'
        page.draggable 'dynamic-bookmark'
        page.replace_html 'dynamic-bookmark', :partial => 'bookmarks/bookmark_form', :locals => {:bookmarkable => bookmarkable}
        page.insert_html :top, 'dynamic-bookmark', "<span id='close-popup'></span>"
        page.replace_html 'close-popup', link_to_function("Close", update_page {|page| page.hide 'dynamic-bookmark'})
      end 
    end
  end
  
end
