class ChapterSweeper < ActionController::Caching::Sweeper
  observe Chapter
  
  def after_save(chapter)
    changelist = chapter.changed.empty? ? [] : chapter.changed - %w(updated_at delta)
    expire_chapter_cache_for(chapter) unless changelist.empty?
  end

  def after_destroy(chapter)
    expire_chapter_cache_for(chapter)
  end
  
  private
  def expire_chapter_cache_for(chapter)
    expire_fragment("chapter-show-#{chapter.id}")
    expire_fragment("chapter-show-content-#{chapter.id}")
  end

end
