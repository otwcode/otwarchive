class CollectionIndexer < Indexer

  def self.klass
    "Collection"
  end

  def self.mapping
    {
      "collection" => {
        properties: {
          title: { type: "text", analyzer: "simple" },
          title: {
            type: "text",
            analyzer: "collection_title_analyzer",
            fields: {
              exact: {
                type:     "text",
                analyzer: "exact_collection_analyzer"
              },
              keyword: {
                type: "keyword",
                normalizer: "keyword_lowercase"
              }
            }
          },
          name: { type: "text", analyzer: "simple" },
          description: { type: "text", analyzer: "simple" },
          collection_type: { type: "keyword" },
          created_at: { type: "date" }
        }
      }
    }
  end

  def self.settings
    {
      analysis: {
        analyzer: {
          collection_title_analyzer: {
            type: "custom",
            tokenizer: "standard",
            filter: [
              "lowercase"
            ]
          },
          exact_collection_analyzer: {
            type: "custom",
            tokenizer: "keyword",
            filter: [
              "lowercase"
            ]
          }
        },
        normalizer: {
          keyword_lowercase: {
            type: "custom",
            filter: ["lowercase"]
          }
        }
      }
    }
  end

  def document(object)
    object.as_json(
      root: false,
      only: [
        :id, :name, :title, :description, :parent_id, :collection_type, :created_at
      ]
    ).merge(
      closed: object.closed?,
      moderated: object.moderated?,
      unrevealed: object.unrevealed?,
      anonymous: object.anonymous?,
      owner_ids: object.all_owners.pluck(:id),
      moderator_ids: object.all_moderators.pluck(:id),

      # signup_open
      # general_fandom_ids
      # general_fandoms_count
      # general_works_count
      # general_bookmarked_items_count
      # signups_open_at
      # signups_close_at
      # assignments_due_at
      # works_reveal_at
      # authors_reveal_at


      # decorator
      # 
      # general_fandoms_count
      # general_works_count
      # general_bookmarked_items_count
      # public_fandoms_count: object.all_fandoms_count,
      # public_works_count: object.all_approved_works_count
      # public_bookmarked_items_count: object.all_approved_bookmarks_count
    )
  end
end
