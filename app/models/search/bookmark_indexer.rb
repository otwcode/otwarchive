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

  # index_all without background jobs
  def self.index_all_foreground
    delete_index
    create_index
    BookmarkedExternalIndexer.new(ExternalWork.all.pluck(:id)).index_documents rescue nil
    BookmarkedSeriesIndexer.new(Series.all.pluck(:id)).index_documents rescue nil
    BookmarkedWorkIndexer.new(BookmarkedWorkIndexer.indexables.pluck(:id)).index_documents rescue nil
    self.new(Bookmark.all.pluck(:id)).index_documents rescue nil
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
          "bookmarkable_tag" => {
            "type" => "text",
            "analyzer" => "simple"
          },
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
    tag_filters = tags.map(&:filter).compact

    bookmarkable = nil

    if object.respond_to?(:bookmarkable)
      bookmarkable = object.bookmarkable
      bookmarkable_filters = bookmarkable.tags.map(&:filter).compact
    end

    json_object = object.as_json(
      root: false,
      except: [:notes_sanitizer_version, :delta],
      methods: [:bookmarker, :collection_ids, :with_notes]
    ).merge(
      user_id: object.pseud.user_id,
      tag: (tags + tag_filters).map(&:name).uniq,
      tag_ids: tags.map(&:id),
      filter_ids: tag_filters.map(&:id) + bookmarkable_filters.map(&:id),
      bookmarkable_posted: !bookmarkable || (bookmarkable && bookmarkable.posted),
      bookmarkable_hidden_by_admin: !!bookmarkable && bookmarkable.hidden_by_admin
    )

    unless parent_id(object).match("deleted")
      json_object.merge!(
        bookmarkable: {
          name: "bookmark",
          parent: parent_id(object)
        }
      )
    end

    json_object
  end

  def deleted_bookmmark_info(id)
    REDIS_GENERAL.get("deleted_bookmark_parent_#{id}")
  end
end
