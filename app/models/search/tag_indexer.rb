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
          tag_type: { type: "keyword" },
          sortable_name: { type: "keyword" },
          uses: { type: "integer" }
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
    ).merge(
      tag_type: object.type,
      uses: object.taggings_count_cache,
      sortable_name: object.name.downcase
    ).merge(parent_data(object))
  end

  # Index parent data for tag wrangling searches
  def parent_data(tag)
    data = {}
    %w(Media Fandom Character).each do |parent_type|
      if tag.parent_types.include?(parent_type)
        key = "#{parent_type.downcase}_ids"
        ids = tag.parents.by_type(parent_type).pluck(:id)
        # add a dummy value so we can find the unwrangled tags more easily
        # since you can't search for an empty array
        data[key] = ids.empty? ? [0] : ids
        next if parent_type == "Media"
        data["pre_#{key}"] = tag.suggested_parent_ids(parent_type)
      end
    end
    data
  end

end
