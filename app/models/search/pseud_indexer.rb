class PseudIndexer < Indexer

  def self.klass
    "Pseud"
  end

  def self.klass_with_includes
    Pseud.includes(:user, :collections)
  end

  def self.mapping
    {
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
          analyzer: "standard"
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
  end

  def self.index_all(options = {})
    unless options[:skip_delete]
      delete_index
      create_index(shards: ArchiveConfig.PSEUD_SHARDS)
    end
    options[:skip_delete] = true
    super(options)
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
    counts = work_counts[pseud.id] || {}
    {
      sortable_name: pseud.name.downcase,
      fandoms: fandoms(pseud),
      general_bookmarks_count: general_bookmarks_counts[pseud.id] || 0,
      public_bookmarks_count: public_bookmarks_counts[pseud.id] || 0,
      general_works_count: counts.values.sum,
      public_works_count: counts[false] || 0
    }
  end

  private

  def batch_pseud_ids
    @batch_pseud_ids ||= Array(ids).map(&:to_i)
  end

  def fandoms(pseud)
    fandom_info[pseud.id] || []
  end

  def fandom_info
    @fandom_info ||= begin
      info = {}
      fandom_counts(countable_works).each do |(pseud_id, id, name), count|
        (info[pseud_id] ||= []) << { id: id, name: name, count: count }
      end
      public_works = countable_works.where(restricted: false)
      fandom_counts(public_works).each do |(pseud_id, id, name), count|
        (info[pseud_id] ||= []) <<
          { id_for_public: id, name: name, count: count }
      end
      info
    end
  end

  def fandom_counts(works)
    works.joins(:direct_filters)
      .merge(Tag.by_type("Fandom"))
      .group("creatorships.pseud_id", "tags.id", "tags.name")
      .count
  end

  # The relation containing all bookmarks that should be included in the count
  # for logged-in users (when restricted to a particular pseud).
  def general_bookmarks
    @general_bookmarks ||=
      Bookmark.with_missing_bookmarkable
        .or(Bookmark.with_bookmarkable_visible_to_registered_user)
        .is_public
  end

  # The relation containing all bookmarks that should be included in the count
  # for logged-out users (when restricted to a particular pseud).
  def public_bookmarks
    @public_bookmarks ||=
      Bookmark.with_missing_bookmarkable
        .or(Bookmark.with_bookmarkable_visible_to_all)
        .is_public
  end

  def general_bookmarks_counts
    @general_bookmarks_counts ||=
      general_bookmarks.where(pseud_id: batch_pseud_ids)
        .group(:pseud_id).count
  end

  def public_bookmarks_counts
    @public_bookmarks_counts ||=
      public_bookmarks.where(pseud_id: batch_pseud_ids)
        .group(:pseud_id).count
  end

  def work_counts
    @work_counts ||= countable_works
      .group("creatorships.pseud_id", :restricted).count
      .each_with_object({}) do |((pseud_id, restricted), count), counts|
        (counts[pseud_id] ||= {})[restricted] = count
      end
  end

  def countable_works
    Work.where(countable_works_conditions)
      .joins(:creatorships)
      .merge(Creatorship.approved)
      .where(creatorships: { pseud_id: batch_pseud_ids })
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
