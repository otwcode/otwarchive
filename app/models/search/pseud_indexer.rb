class PseudIndexer < Indexer
  def self.klass
    "Pseud"
  end

  def self.klass_with_includes
    Pseud.includes(
      :user,
      :collections,
      bookmarks: :bookmarkable,
      works: [:tags]
    )
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
    work_counts = work_counts(pseud)
    {
      sortable_name: pseud.name.downcase,
      fandoms: fandoms(pseud),
      general_bookmarks_count: general_bookmarks_count(pseud),
      public_bookmarks_count: public_bookmarks_count(pseud),
      general_works_count: work_counts.values.sum,
      public_works_count: work_counts[false] || 0
    }
  end

  private

  def fandoms(pseud)
    tag_info(pseud, "Fandom")
  end

  # Produces an array of hashes with the format
  # [{id: 1, name: "Star Trek", count: 5}]
  def tag_info(pseud, tag_type)
    filters = pseud.works.flat_map(&:direct_filters).select { |f| f.type == tag_type }

    general = filters.select { |f| f.works.any? { |w| countable_work?(w) } }
    info = general.group_by(&:id).map do |id, tags|
      { id: id, name: tags.first.name, count: tags.size }
    end

    public_filters = filters.select { |f| f.works.any? { |w| countable_work?(w) && !w.restricted } }
    info += public_filters.group_by(&:id).map do |id, tags|
      { id_for_public: id, name: tags.first.name, count: tags.size }
    end

    info
  end

  def general_bookmarks_count(pseud)
    pseud.bookmarks.select do |b|
      b.is_public && b.bookmarkable_visible_to_registered_user?
    end.size
  end

  def public_bookmarks_count(pseud)
    pseud.bookmarks.select do |b|
      b.is_public && b.bookmarkable_visible_to_all?
    end.size
  end

  def work_counts(pseud)
    counts = { true => 0, false => 0 }

    pseud.works.each do |work|
      next unless countable_work?(work)

      counts[work.restricted] += 1
    end

    counts
  end

  def countable_work?(work)
    work.posted &&
      !work.hidden_by_admin &&
      !work.in_anon_collection &&
      !work.in_unrevealed_collection
  end
end
