module WorkBookmarkCountCaching
  def key_for_bookmark_counting_public
    "/v1/bookmark_count_public/#{self.id}"
  end

  def work_bookmarks_public_count
    Rails.cache.fetch(self.key_for_bookmark_counting_public) do
      self.bookmarks.is_public.count
    end
  end

  def invalidate_work_bookmark_count
    Rails.cache.delete(self.key_for_bookmark_counting_public)
  end
end
