class CollectionIndexer < Indexer

  def self.klass
    "Collection"
  end

  def self.mapping
    {
      "collection" => {
        properties: {
          title: { type: "text", analyzer: "simple" },
          name: { type: "text", analyzer: "simple" },
          description: { type: "text", analyzer: "simple" },
          collection_type: { type: "keyword" },
          created_at: { type: "date" }
        }
      }
    }
  end

  def document(object)
    object.as_json(
      root: false,
      only: [
        :id, :name, :title, :description, :parent_id, :collection_type, :created_at
      ],
      methods: [
        :signup_open
      ]
    ).merge(
      closed: object.closed?,
      moderated: object.moderated?,
      unrevealed: object.unrevealed?,
      anonymous: object.anonymous?,
      owner_ids: object.all_owners.pluck(:id),
      moderator_ids: object.all_moderators.pluck(:id),

      public_fandom_ids: object.all_fandoms.pluck(:id),
      public_fandoms_count: object.all_fandoms_count,
      public_works_count: object.all_approved_works_count,
      public_bookmarked_items_count: object.all_approved_bookmarks_count

      # general_fandom_ids
      # general_fandoms_count
      # general_works_count
      # general_bookmarked_items_count
      # signups_open_at
      # signups_close_at
      # assignments_due_at
      # works_reveal_at
      # authors_reveal_at
    )
  end
end
