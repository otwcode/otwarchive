class TagIndexer < Indexer

  def self.klass
    'Tag'
  end

  def self.mapping
    {
      tag: {
        properties: {
          name: {
            type: 'string',
            analyzer: 'simple'
          },
          tag_type: {
            type: 'string',
            index: 'not_analyzed'
          }
        }
      }
    }
  end

  def document(object)
    object.as_json(
      root: false,
      only: [:id, :name, :merger_id, :canonical, :created_at]
    ).merge(tag_type: object.type)
  end

end
