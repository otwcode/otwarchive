module ES
  class BookmarkedSeriesIndexer < ES::BookmarkableIndexer
    def self.klass
      "Series"
    end
  end
end