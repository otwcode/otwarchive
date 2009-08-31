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
        fallback = new_external_work_bookmark_path(bookmarkable)
        blurb == true ? text = t('save_bookmark', :default => 'Save') :
        text = t('add_new_bookmark', :default => 'Add A New Bookmark')
      elsif bookmarkable.class == Series
        fallback = new_series_bookmark_path(bookmarkable)
        blurb == true ? text = t('save_bookmark', :default => 'Save') : text = t('bookmark', :default => 'Bookmark Series')
      end
      # Check to see if the user has an existing bookmark on this object. Note: on work page we eventually want to change this so an 
      # existing bookmark is opened for editing but a new bookmark can be created by selecting a different pseud on the form.
      @existing = Bookmark.find(:all, :conditions => ["bookmarkable_type = ? AND bookmarkable_id = ? AND pseud_id IN (?)", bookmarkable.class.name.to_s, bookmarkable.id, current_user.pseuds.collect(&:id)])
      if @existing.blank?                                         
        link_to_remote text, {:url => fallback, :method => :get}, :href => fallback
      else
        # eventually we want to add the option here to remove the existing bookmark
        # Enigel Dec 10 08 - adding an edit link for now
        if blurb == true 
          if @existing.many?
            string = bookmarkable.class.to_s.underscore
            path = string + "_bookmarks_path(bookmarkable, :existing => true)"
            link_to t('saved_bookmarks', :default => 'Saved'), eval(path) 
          else
            link_to t('saved_bookmark', :default => 'Saved'), bookmark_path(@existing)
          end
        else 
          if @existing.many?
            link_to t('edit_bookmark', :default => "Edit/Add Bookmark"), edit_bookmark_path(@existing.last, :existing => true)
          else
            link_to t('edit_bookmark', :default => "Edit/Add Bookmark"), edit_bookmark_path(@existing.last, :existing => false)
          end
        end      
      end
    end
  end
  
  def link_to_new_bookmarkable_bookmark(bookmarkable)
    string = bookmarkable.class.to_s.underscore
    path = "new_" + string + "_bookmark_path(bookmarkable)"
    link_to "Add a new bookmark for this item", eval(path)
  end
  
  def link_to_user_bookmarkable_bookmarks(bookmarkable)
    string = bookmarkable.class.to_s.underscore
    path = string + "_bookmarks_path(bookmarkable, :existing => true)"
    link_to "You have saved multiple bookmarks for this item", eval(path)
  end
  
  # tag_bookmarks_path was behaving badly for tags with slashes
  def link_to_tag_bookmarks(tag)
    {:controller => 'bookmarks', :action => 'index', :tag_id => tag}
  end
  
  def link_to_bookmarkable_bookmarks(bookmarkable, link_text='')
    if link_text.blank? 
      link_text = Bookmark.count_visible_bookmarks(bookmarkable, current_user)
    end
    link_to link_text, eval(bookmarkable.class.to_s.underscore + "_bookmarks_path(bookmarkable)")
  end
  
  def get_symbol_for_bookmark(bookmark)
    if bookmark.private?
      img = "bookmark-private"
      title_string = "Private Bookmark"
    elsif bookmark.hidden_by_admin?
      img = "bookmark-hidden"
      title_string = "Bookmark Hidden by Admin"
    elsif bookmark.rec?
      img = "bookmark-rec"
      title_string = "Rec"
    else
      img = "bookmark-public"
      title_string = "Public Bookmark"
    end
    '<li>' + link_to_help('bookmark-symbols-key', link = image_tag( "#{img}.png", :alt => title_string, :title => title_string)) + '</li>'
  end
  
  def toggle_recs_bookmarks
    if params[:recs_only]
      link_to "View All Bookmarks", url_for(:overwrite_params => {:recs_only => false})        
    else
      link_to "View Recs Only", url_for(:overwrite_params => {:recs_only => true})
    end
  end
  
end
