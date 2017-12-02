class BookmarkableIndexer < Indexer

  def self.index_name
    "ao3_#{Rails.env}_bookmarks"
  end

  def self.document_type
    'bookmark'
  end

  def self.mapping
    BookmarkIndexer.mapping
  end

  def routing_info(id)
    {
      '_index' => index_name,
      '_type' => document_type,
      '_id' => document_id(id)
    }
  end

  def document(object)
    object.bookmarkable_json
  end

  def document_id(id)
    "#{id}-#{klass.underscore}"
  end

end
