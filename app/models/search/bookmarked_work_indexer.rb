class BookmarkedWorkIndexer < BookmarkableIndexer
  def self.klass
    "Work"
  end

  # Only index works with bookmarks
  def self.indexables
    Work.includes(:stat_counter).where("stat_counters.bookmarks_count > 0").references(:stat_counters)
  end
end
