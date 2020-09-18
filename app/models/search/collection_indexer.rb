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
          collection_type: { type: "keyword" }
        }
      }
    }
  end

  def document(object)
    object.as_json(
      root: false,
      only: [
        :id, :name, :title, :created_at, :description,
        :parent_id, :collection_type
      ],
      methods: [
        :signup_open,
        :moderated,
        :unrevealed,
        :anonymous
      ]
    ).merge(
      closed: object.closed?,
      moderated: object.moderated?,
      unrevealed: object.unrevealed?,
      anonymous: object.anonymous?
      
      # signups_open_at: signups_open_at,
      # signups_close_at: signups_close_at,
      # assignments_due_at: assignments_due_at,
      # works_reveal_at: works_reveal_at,
      # authors_reveal_at: authors_reveal_at
    )
  end
end
