module ES
  class BookmarkedExternalWorkIndexer < ES::BookmarkableIndexer

    def self.klass
      "ExternalWork"
    end

    def self.mapping
    end

    def document(object)
    end

  end
end