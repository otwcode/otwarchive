module ES
  class BookmarkedWorkIndexer < ES::BookmarkableIndexer
    def self.klass
      "Work"
    end
  end
end