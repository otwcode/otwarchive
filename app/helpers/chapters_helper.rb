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

  # returns ARRAY of next/previous links as appropriate with the given chapter as the starting point
  def next_and_previous_links(work, chapter)
    number_of_chapters = work.chapters.in_order.size 
    chapter_position = work.chapters.in_order.index(chapter)
    links = []
    
    links << link_to_chapter("First Chapter".t, work, 0)
    links << (chapter_position == 0 ? 
                "Previous Chapter".t : 
                link_to_chapter("Previous Chapter".t, work, chapter_position-1))
    links << (chapter_position == (number_of_chapters - 1) ? 
                "Next Chapter".t : 
                link_to_chapter("Next Chapter".t, work, chapter_position+1))
    links << link_to_chapter("Last Chapter".t, work, number_of_chapters-1)
  end

  # returns LIST ITEMS with next/previous links as appropriate with the given chapter as the starting point
  def next_and_previous_links_listitems(work, chapter)
    links = next_and_previous_links(work, chapter)
    links.collect {|link| "<li>" + link + "</li>\n"}
  end
  
  def link_to_chapter(string, work, chapter_position)
    link_to_unless_current string, 
      url_for({:controller => :chapters, :action => :show, :work_id => work, 
               :id => work.chapters.in_order[chapter_position]})
  end
  
end
