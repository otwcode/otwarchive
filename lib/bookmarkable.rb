module Bookmarkable

  def self.included(bookmarkable)
    bookmarkable.class_eval do
      has_many :bookmarks, :as => :bookmarkable
      has_many :user_tags, :through => :bookmarks, :source => :tags
      after_update :update_bookmarks_index
    end
  end

  def public_bookmark_count
    self.bookmarks.is_public.count
  end

  def update_bookmarks_index
    self.bookmarks.each{ |bookmark| bookmark.update_index }
  end

end
