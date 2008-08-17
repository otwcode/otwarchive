module ChaptersHelper 
  
  # Creates a link with the appropriate chapter number
  def chapter_link(chapter)
    chapter_header = "Chapter ".t + (chapter.position_placeholder || chapter.current_position).to_s
    link_to chapter_header, [chapter.work, chapter]
  end
  
  # Creates a link to show or hide comments on the chapter index page
  def index_show_hide_comments_link
    if params[:show_comments]
      link_to "Hide comments".t, :controller => :chapters, :action => :index, :work_id => @work.id
    else
      link_to_remote("Show comments".t, {:url =>{ :controller => :comments, :action => :showcomments, :work_id => (@work.id)}}, :href => url_for(:controller => :chapters, :action => 'index', :work_id => @work.id, :show_comments => true))
    end
  end 
  
end
