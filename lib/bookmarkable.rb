module Bookmarkable
  def self.included(bookmarkable)
    bookmarkable.class_eval do
      has_many :bookmarks, as: :bookmarkable, inverse_of: :bookmarkable
      has_many :user_tags, through: :bookmarks, source: :tags
      after_update :update_bookmarks_index
      after_update :update_bookmarker_pseuds_index, :update_bookmarker_collections_index
      after_destroy :update_bookmarker_pseuds_index, :update_bookmarker_collections_index
    end
  end

  def public_bookmark_count
    Rails.cache.fetch("#{self.cache_key}/bookmark_count", expires_in: 2.hours) do
      self.bookmarks.is_public.count
    end
  end

  def update_bookmarks_index
    IndexQueue.enqueue_ids(Bookmark, bookmarks.pluck(:id), :background)
  end

  def update_bookmarker_pseuds_index
    return unless respond_to?(:should_update_pseud_and_collection_indexes?)
    return unless should_update_pseud_and_collection_indexes?

    IndexQueue.enqueue_ids(Pseud, bookmarks.pluck(:pseud_id), :background)
  end

  def update_bookmarker_collections_index
    return unless respond_to?(:should_update_pseud_and_collection_indexes?)
    return unless should_update_pseud_and_collection_indexes?

    collection_ids = Collection
      .joins(:collection_items)
      .joins("INNER JOIN bookmarks ON bookmarks.id = collection_items.item_id AND collection_items.item_type = 'Bookmark'")
      .where(bookmarks: { bookmarkable_id: id, bookmarkable_type: self.class.name })
      .where(collection_items: { user_approval_status: 1, collection_approval_status: 1 })
      .pluck("collections.id", "collections.parent_id")
      .flatten.uniq.compact

    IndexQueue.enqueue_ids(Collection, collection_ids, :background)
  end
end
