class CollectionIndexer < Indexer
  def self.klass
    "Collection"
  end

  def self.klass_with_includes
    Collection.includes(
      :collection_preference,
      :challenge,
      :children,
      :parent,
      :owners,
      :moderators,
      :filters,
      :tags
    )
  end

  def self.index_all(**options)
    unless options[:skip_delete]
      delete_index
      create_index(shards: ArchiveConfig.COLLECTION_SHARDS)
    end
    options[:skip_delete] = true
    super(options)
  end

  def self.mapping
    {
      properties: {
        title: {
          type: "text",
          analyzer: "collection_title_analyzer",
          fields: {
            exact: {
              type: "text",
              analyzer: "exact_collection_analyzer"
            },
            keyword: {
              type: "keyword",
              normalizer: "keyword_lowercase"
            }
          }
        },
        challenge_type: {
          type: "keyword",
          null_value: "NULL"
        },
        name: { type: "text", analyzer: "simple" },
        description: { type: "text", analyzer: "standard" }
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
        :id, :name, :title, :description, :parent_id, :challenge_type, :multifandom, :open_doors, :created_at
      ],
      methods: %i[general_works_count public_works_count general_bookmarked_items_count public_bookmarked_items_count]
    ).merge(
      closed: object.closed?,
      unrevealed: object.unrevealed?,
      anonymous: object.anonymous?,
      owner_ids: object.all_owners.pluck(:user_id),
      moderated: object.moderated?,
      moderator_ids: object.all_moderators.pluck(:user_id),
      maintainer_ids: object.maintainers.pluck(:user_id),
      signup_open: object.challenge&.signup_open,
      signups_open_at: object.challenge&.signups_open_at,
      signups_close_at: object.challenge&.signups_close_at,
      assignments_due_at: object.challenge&.assignments_due_at,
      works_reveal_at: object.challenge&.works_reveal_at,
      authors_reveal_at: object.challenge&.authors_reveal_at,
      filter_ids: object.filter_ids,
      tag: object.tag
    )
  end
end
