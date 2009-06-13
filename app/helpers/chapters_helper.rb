module ChaptersHelper
  
  def chapter_title_with_position(chapter)
    chapter.position.to_s + '. ' + chapter_title(chapter)
  end
  
  def chapter_title(chapter)
    chapter.title.blank? ? t('alt_title', :default => "Chapter {{position}}", :position => chapter.position) : chapter.title
  end
  
  def chapter_link_with_title(chapter)
    link_to_unless_current chapter_title(chapter), [chapter.work, chapter]
  end 
  
  # Creates a link with the appropriate chapter number
  def chapter_link(chapter)
    chapter_header = "Chapter " + chapter.position.to_s
    link_to chapter_header, [chapter.work, chapter]
  end
  
  # returns ARRAY of next/previous links as appropriate with the given chapter as the starting point
  def next_and_previous_links(work, chapter)
    if logged_in? && current_user.is_author_of?(work)
      number_of_chapters = work.chapters.in_order.size 
      chapter_position = work.chapters.in_order.index(chapter)
    else
      number_of_chapters = work.chapters.posted.in_order.size 
      chapter_position = work.chapters.posted.in_order.index(chapter)
    end
    links = []
    
    links << link_to_chapter("First Chapter", work, 0)
    links << (chapter_position == 0 ? 
                "Previous Chapter" : 
                link_to_chapter("Previous Chapter", work, chapter_position-1))
    links << (chapter_position == (number_of_chapters - 1) ? 
                "Next Chapter" : 
                link_to_chapter("Next Chapter", work, chapter_position+1))
    links << link_to_chapter("Last Chapter", work, number_of_chapters-1)
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
  
  # Sets default published_at date on chapter form if @work.backdate_default is true
  def default_date
    if @work.backdate
      @work.first_chapter.published_at
    else
      Date.today
    end
  end
end
