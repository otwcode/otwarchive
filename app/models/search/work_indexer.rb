class WorkIndexer < Indexer
  def self.klass
    "Work"
  end

  def self.klass_with_includes
    Work.includes(
      :approved_collections,
      :direct_filters,
      :external_author_names,
      :filters,
      :language,
      :stat_counter,
      :tags,
      :users,
      :relationships,
      fandoms: { meta_tags: :meta_tags, merger: { meta_tags: :meta_tags } },
      pseuds: :user,
      serial_works: :series
    )
  end

  def self.index_all(options = {})
    unless options[:skip_delete]
      delete_index
      create_index(shards: ArchiveConfig.WORKS_SHARDS)
    end
    options[:skip_delete] = true
    super(options)
  end

  def self.mapping
    {
      properties: {
        creator_join: {
          type: :join,
          relations: { work: :creator }
        },
        title: {
          type: "text",
          analyzer: "standard"
        },
        creators: {
          type: "text"
        },
        tag: {
          type: "text"
        },
        series: {
          type: "object"
        },
        authors_to_sort_on: {
          type: "keyword"
        },
        title_to_sort_on: {
          type: "keyword"
        },
        imported_from_url: {
          type: "keyword"
        },
        work_types: {
          type: "keyword"
        },
        posted: { type: "boolean" },
        restricted: { type: "boolean" },
        hidden_by_admin: { type: "boolean" },
        complete: { type: "boolean" },
        in_anon_collection: { type: "boolean" },
        in_unrevealed_collection: { type: "boolean" }
      }
    }
  end

  def document(object)
    object.as_json(
      root: false,
      only: [
        :id, :expected_number_of_chapters, :created_at, :updated_at,
        :major_version, :minor_version, :posted, :restricted,
        :title, :summary, :notes, :word_count, :hidden_by_admin, :revised_at,
        :title_to_sort_on, :backdate, :endnotes,
        :imported_from_url, :complete, :work_skin_id, :in_anon_collection,
        :in_unrevealed_collection,
      ],
      methods: [
        :authors_to_sort_on,
        :collection_ids,
        :hits,
        :comments_count,
        :kudos_count,
        :bookmarks_count,
        :creators,
        :crossover,
        :otp,
        :work_types,
        :nonfiction
      ]
    ).merge(
      rating_ids: object.general_rating_ids,
      archive_warning_ids: object.general_archive_warning_ids,
      category_ids: object.general_category_ids,
      fandom_ids: object.general_fandom_ids,
      character_ids: object.general_character_ids,
      relationship_ids: object.general_relationship_ids,
      freeform_ids: object.general_freeform_ids,
      filter_ids: object.general_filter_ids,
      language_id: object.language&.short,
      series: series_data(object),
      tag: object.general_tags,
      creator_join: { name: :work }
    ).merge(creator_data(object))
  end

  def creator_data(work)
    if work.anonymous? || work.unrevealed?
      {}
    else
      {
        user_ids: work.user_ids,
        pseud_ids: work.pseud_ids
      }
    end
  end

  # Format the id, title, and position of each series as a hash:
  def series_data(object)
    object.serial_works.map do |sw|
      {
        id: sw.series_id,
        title: sw.series&.title,
        position: sw.position
      }
    end
  end
end
