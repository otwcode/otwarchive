# This module is included by both the work and chapter models
module WorkChapterCountCaching
  def key_for_chapter_posted_counting(work)
    "/v1/chapters_posted/#{work.id}"
  end

  def key_for_chapter_total_counting(work)
    "/v1/chapters_total/#{work.id}"
  end

  def invalidate_work_chapter_count(work)
    # Caching is not configured on development environments
    # Trying to delete a non-existent cache made chapter deletion fail
    unless Rails.env == "development"
      Rails.cache.delete(key_for_chapter_total_counting(work))
      Rails.cache.delete(key_for_chapter_posted_counting(work))
    end
  end
end
