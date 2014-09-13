module ES
  class BookmarkedSeriesIndexer < ES::BookmarkableIndexer

    def self.klass
      "Series"
    end

    def self.mapping
    end

    def document(object)
    end

  end
end