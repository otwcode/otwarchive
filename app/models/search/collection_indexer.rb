class CollectionIndexer < Indexer

  def self.klass
    "Collection"
  end

  def self.mapping
    {
      "collection" => {
        properties: {
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
      unrevealed: object.unrevealed?,
      anonymous: object.anonymous?,
      owner_ids: object.all_owners.pluck(:user_id),
      moderated: object.moderated?,
      moderator_ids: object.all_moderators.pluck(:user_id),
      challenge_type: object.challenge_type,
      signup_open: object.challenge&.signup_open,
      signups_open_at: object.challenge&.signups_open_at,
      signups_close_at: object.challenge&.signups_close_at,
      assignments_due_at: object.challenge&.assignments_due_at,
      works_reveal_at: object.challenge&.works_reveal_at,
      authors_reveal_at: object.challenge&.authors_reveal_at,
      general_fandom_ids: get_fandom_ids(object),
      public_fandom_ids: get_fandom_ids(object, true),
      general_fandoms_count: get_fandom_ids(object).count,
      public_fandoms_count: get_fandom_ids(object, true).count,
      general_works_count: object.all_approved_works.count,
      public_works_count: object.all_approved_works.where(restricted: false).count,
      general_bookmarked_items_count: get_bookmarked_items_count(object), 
      public_bookmarked_items_count: get_bookmarked_items_count(object, true),
    )
  end

  def get_fandom_ids(collection, only_public = false)
    approved_works = collection.all_approved_works
    approved_works = approved_works.where(restricted: false) if only_public

    approved_works.map(&:fandoms).flatten.pluck(:id)
  end

  def get_bookmarked_items_count(collection, is_public = false)
    bookmarks = Bookmark.is_public.joins(:collection_items)
                .merge(CollectionItem.approved_by_collection)
                .where(collection_items: { collection_id: collection.children.ids + [collection.id] })

    bookmarks = bookmarks.select{ |b| b.bookmarkable.restricted == false } if is_public == true

    bookmarks.count
  end
end
