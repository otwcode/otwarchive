class BookmarkableIndexer < Indexer

  def self.index_name
    "ao3_#{Rails.env}_bookmarks"
  end

  def self.document_type
    'bookmarkable'
  end

  def self.mapping
    {
      'bookmarkable' => {
        properties: {
          title: {
            type: 'string',
            analyzer: 'simple'
          },
          creators: {
            type: 'string',
            analyzer: 'simple',
            index_name: 'creator'
          },
          tag: {
            type: 'string',
            analyzer: 'simple'
          },
          work_types: {
            type: 'string',
            index: 'not_analyzed',
            index_name: 'work_type'
          }
        }
      }
    }
  end

  def routing_info(id)
    {
      '_index' => index_name,
      '_type' => document_type,
      '_id' => "#{id}-#{klass.underscore}"
    }
  end

  def document(object)
    object.bookmarkable_json
  end    

end
