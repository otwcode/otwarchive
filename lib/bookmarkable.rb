module Bookmarkable

  def self.included(bookmarkable)
    bookmarkable.class_eval do
      has_many :bookmarks, :as => :bookmarkable
      has_many :user_tags, :through => :bookmarks, :source => :tags
      after_update :update_bookmarks_index
    end
  end

  def public_bookmark_count
    Rails.cache.fetch("#{self.cache_key}/bookmark_count", :expires_in => 2.hours) do
      self.bookmarks.is_public.count
    end
  end

  def update_bookmarks_index
    RedisSearchIndexQueue.queue_bookmarks(self.bookmarks.pluck :id)
  end

end
