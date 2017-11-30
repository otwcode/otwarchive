class BookmarkIndexer < Indexer

  def self.klass
    "Bookmark"
  end

  # Create the bookmarkable index/mapping first
  # Skip delete on the subclasses so it doesn't delete the ones we've just
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
          "bookmarkable_join" => {
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
          "bookmarkable_type" => {
            "type" => "keyword"
          },
          "bookmarker" => {
            type: "text",
            analyzer: "simple"
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
      "_id" => id.to_s,
      "routing" => parent_id(object)
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
    json_object = object.as_json(
      root: false,
      except: [:notes_sanitizer_version, :delta],
      methods: [:bookmarker, :collection_ids, :with_notes, :bookmarkable_date]
    ).merge(
      user_id: object.pseud&.user_id,
      tag: tags.map(&:name),
      tag_ids: tags.map(&:id)
    )

    unless parent_id(object).match("deleted")
      json_object.merge!(
        bookmarkable_join: {
          name: "bookmark",
          parent: parent_id(object)
        }
      )
    end

    json_object
  end

  def deleted_bookmark_info(id)
    REDIS_GENERAL.get("deleted_bookmark_parent_#{id}")
  end
end
