class BookmarkIndexer < Indexer

  def self.klass
    "Bookmark"
  end

  # Create the bookmarkable index/mapping first
  # Skip delete on the subclasses so it doesn"t delete the ones we"ve just
  # reindexed
  def self.index_all(options={})
    options[:skip_delete] = true
    BookmarkableIndexer.delete_index
    BookmarkableIndexer.create_index
    create_mapping
    BookmarkedExternalWorkIndexer.index_all(skip_delete: true)
    BookmarkedSeriesIndexer.index_all(skip_delete: true)
    BookmarkedWorkIndexer.index_all(skip_delete: true)
    super
  end

  def self.mapping
    {
      "bookmark" => {
        "properties" => {
          "bookmarkable" => {
            "type" => "join",
            "relations" => {
              "bookmarkable" => "bookmark"
            }
          },
          "title" => {
            "type" => "text",
            "analyzer" => "simple"
          },
          "creators" => {
            "type" => "text",
            "analyzer" => "simple"
          },
          "work_types" => {
            "type" => "keyword"
          },
          # "bookmarkable_tag" => {
          #   "type" => "text",
          #   "analyzer" => "simple"
          # },
          "bookmarkable_type" => {
            "type" => "keyword"
          },
          "bookmarker" => {
            type: "text",
            analyzer: "snowball"
          },
          "tag" => {
            "type" => "text",
            "analyzer" => "simple"
          }
        }
      }
    }
  end

  ####################
  # INSTANCE METHODS
  ####################

  def routing_info(id)
    object = objects[id.to_i]
    {
      "_index" => index_name,
      "_type" => document_type,
      "_id" => id,
      "parent" => parent_id(object)
    }
  end

  def parent_id(object)
    if object.nil?
      deleted_bookmark_info(object.id)
    else
      "#{object.bookmarkable_id}-#{object.bookmarkable_type.underscore}"
    end
  end

  def document(object)
    tags = object.tags
    filters = tags.map{ |t| t.filter }.compact
    bookmarkable = object.bookmarkable if object.respond_to? :bookmarkable

    object.as_json(
      root: false,
      except: [:notes_sanitizer_version, :delta],
      methods: [:bookmarker, :collection_ids, :with_notes]
    ).merge(
      user_id: object.pseud.user_id,
      tag: (tags + filters).map(&:name).uniq,
      tag_ids: tags.map(&:id),
      filter_ids: filters.map(&:id),
      bookmarkable_posted: !bookmarkable || (bookmarkable && bookmarkable.posted),
      bookmarkable_hidden_by_admin: !!bookmarkable && bookmarkable.hidden_by_admin,
      position: {
        name: "bookmark",
        parent: parent_id(object)
      }
    )
  end

  def deleted_bookmmark_info(id)
    REDIS_GENERAL.get("deleted_bookmark_parent_#{id}")
  end
end
