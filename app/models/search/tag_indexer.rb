class TagIndexer < Indexer

  def self.klass
    "Tag"
  end

  def self.mapping
    {
      tag: {
        properties: {
          name: {
            type: "text",
            analyzer: "simple"
          },
          tag_type: {
            type: "keyword"
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
