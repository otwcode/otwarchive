class BookmarkIndexer < Indexer

  def self.klass
    'Bookmark'
  end

  # Create the bookmarkable index/mapping first
  # Skip delete on the subclasses so it doesn't delete the ones we've just reindexed
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
        "_parent" => {
          type: 'bookmarkable'
        },
        properties: {
          bookmarkable_type: {
            type: 'string',
            index: 'not_analyzed'
          },
          bookmarker: {
            type: 'string',
            analyzer: 'simple'
          },
          notes: {
            type: 'string',
            analyzer: 'snowball'
          },
          tag: {
            type: 'string',
            analyzer: 'simple'
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
    if object.nil?
      parent_id = deleted_bookmark_info(id)
    else
      parent_id = "#{object.bookmarkable_id}-#{object.bookmarkable_type.underscore}"
    end
    { 
      '_index' => index_name, 
      '_type' => document_type,
      '_id' => id,
      'parent' => parent_id
    }
  end

  def document(object)
    tags = object.tags
    filters = tags.map{ |t| t.filter }.compact

    object.as_json(
      root: false,
      except: [:notes_sanitizer_version, :delta],
      methods: [:bookmarker, :collection_ids, :with_notes]
    ).merge(
      user_id: object.pseud.user_id,
      tag: (tags + filters).map(&:name).uniq,
      tag_ids: tags.map(&:id),
      filter_ids: filters.map(&:id)
    )
  end

  def deleted_bookmark_info(id)
    REDIS_GENERAL.get("deleted_bookmark_parent_#{id}")
  end
end
