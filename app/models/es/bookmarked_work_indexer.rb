module ES
  class BookmarkedWorkIndexer < ES::BookmarkableIndexer

    def self.klass
      "Work"
    end

    def self.mapping
    end

    def document(object)
    end

  end
end