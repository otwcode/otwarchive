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
            analyzer: "tag_name_analyzer",
            fields: {
              exact: {
                type:     "text",
                analyzer: "exact_tag_analyzer"
              }
            }
          },
          tag_type: {
            type: "keyword"
          }
        }
      }
    }
  end

  def self.settings
    {
      analysis: {
        analyzer: {
          tag_name_analyzer: {
            type: "custom",
            tokenizer: "standard",
            filter: [
              "lowercase"
            ]
          },
          exact_tag_analyzer: {
            type: "custom",
            tokenizer: "keyword",
            filter: [
              "lowercase"
            ]
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
