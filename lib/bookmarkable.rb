module Bookmarkable

  def self.included(bookmarkable)
    bookmarkable.class_eval do
      has_many :bookmarks, as: :bookmarkable
      has_many :user_tags, through: :bookmarks, source: :tags
      after_update :update_bookmarks_index
      after_update :update_bookmarker_pseuds_index
    end
  end

  def public_bookmark_count
    Rails.cache.fetch("#{self.cache_key}/bookmark_count", expires_in: 2.hours) do
      self.bookmarks.is_public.count
    end
  end

  def update_bookmarks_index
    RedisSearchIndexQueue.queue_bookmarks(self.bookmarks.pluck :id)
  end

  def update_bookmarker_pseuds_index
    # ES UPGRADE TRANSITION #
    # Remove new indexing check
    return unless $rollout.active?(:start_new_indexing)
    return unless respond_to?(:should_reindex_pseuds?)
    return unless should_reindex_pseuds?
    IndexQueue.enqueue_ids(Pseud, bookmarks.pluck(:pseud_id), :background)
  end
end
