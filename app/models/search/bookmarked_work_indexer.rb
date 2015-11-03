class BookmarkedWorkIndexer < BookmarkableIndexer
  def self.klass
    "Work"
  end

  # Only index works with bookmarks
  def self.indexables
    Work.joins(:stat_counter).where("bookmarks_count > 0")
  end
end
