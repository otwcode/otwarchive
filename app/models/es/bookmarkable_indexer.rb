module ES
  class BookmarkableIndexer < ES::Indexer
  
    def self.index_name
      "ao3_#{Rails.env}_bookmarks"
    end

    def self.document_type
      'bookmarkable'
    end

  end
end