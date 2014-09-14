module ES
  class BookmarkedExternalWorkIndexer < ES::BookmarkableIndexer
    def self.klass
      "ExternalWork"
    end
  end
end