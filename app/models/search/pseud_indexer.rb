class PseudIndexer < Indexer

  def self.klass
    "Pseud"
  end

  def self.mapping
    {
      "pseud" => {
        properties: {
          name: {
            type: "text",
            analyzer: "simple"
          },
          # adding extra name field for sorting
          sortable_name: {
            type: "keyword"
          },
          byline: {
            type: "text",
            analyzer: "simple"
          },
          user_login: {
            type: "text",
            analyzer: "simple"
          },
          fandom: {
            type: "nested"
          }
        }
      }
    }
  end

  def document(object)
    object.as_json(
      root: false,
      only: [:id, :user_id, :name, :description, :created_at],
      methods: [
        :user_login,
        :byline,
        :collection_ids
      ]
    ).merge(extras(object).as_json)
  end

  def extras(pseud)
    {
      sortable_name: pseud.name.downcase,
      fandoms: fandoms(pseud),
      bookmarks_count: bookmarks_count(pseud),
      works_count: works_count(pseud)
    }
  end

  private

  def fandoms(pseud)
    tag_info(pseud, "Fandom")
  end

  # Produces an array of hashes with the format
  # [{id: 1, name: "Star Trek", count: 5}]
  def tag_info(pseud, tag_type)
    pseud.direct_filters.where(works: countable_works_conditions).
                         by_type(tag_type).
                         group_by(&:id).
                         map{ |id, tags| {
                          id: id,
                          name: tags.first.name,
                          count: tags.length }
                         }
  end

  def bookmarks_count(pseud)
    pseud.bookmarks.where(private: false, hidden_by_admin: false).count
  end

  def works_count(pseud)
    pseud.works.where(countable_works_conditions).count
  end

  def countable_works_conditions
    {
      posted: true,
      hidden_by_admin: false,
      in_anon_collection: false,
      in_unrevealed_collection: false
    }
  end
end
