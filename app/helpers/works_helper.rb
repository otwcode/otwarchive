module WorksHelper 
  
  # For use with chapter virtual attributes
  def fields_for_associated(creation, associated, &block)
    fields_for(name_attributes(creation, associated.class.to_s.downcase), associated, &block)
  end
  
  def name_attributes(creation, attribute_type)
   creation + "[" + attribute_type + "_attributes]" 
  end
  
  # Returns message re: number of posted chapters/number of expected chapters 
  def wip_message(work)
    posted = work.number_of_posted_chapters
    posted = 1 if posted == 0
    "Please note this is a work in progress, with ".t + posted.to_s + " of ".t + work.wip_length.to_s + " chapters posted.".t  
  end
  
#  def view_all_chapters_link(work)
#    #link_to_remote "View entire work".t, {:url => {:controller => :chapters, :action => :index, :work_id => work, :old_chapter => chapter.id}, :method => :get},
#    #                                      {:href => work_path(work)} 
#    link_to "View entire work".t, work_path(work) 
#  end
  
  def view_chapter_link(work, chapter)
    #link_to_remote "View by chapters".t, {:url => {:controller => :chapters, :action => :show, :work_id => work, :id => work.first_chapter}, :method => :get},
    #                                        {:href => url_for({:controller => :chapters, :action => :show, :work_id => work, :id => work.first_chapter})} 
    link_to "View by chapters".t, url_for({:controller => :chapters, :action => :show, :work_id => work, :id => chapter})
  end
  
  # Determines whether or not to display warnings for a work 
  def hide_warnings?(work)
    current_user.is_a?(User) && current_user.preference && current_user.preference.hide_warnings? && !current_user.is_author_of?(work)
  end
  
  # Link to show warnings if they're currently hidden
  def show_warnings_link(work, category)
    link_to_remote "Show warnings".t, 
      :url => {:controller => 'tags', :action => 'show_hidden', :work_id => work.id, :category_id => category.id}, 
      :method => :get
  end    
end
