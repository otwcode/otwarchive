class WorkIndexer < Indexer

  def self.klass
    "Work"
  end

  def self.index_all(options = {})
    unless options[:skip_delete]
      delete_index
      create_index(12)
    end
    options[:skip_delete] = true
    super(options)
  end

  def self.mapping
    {
      "work" => {
        properties: {
          title: {
            type: "text",
            analyzer: "simple"
          },
          creators: {
            type: "text"
          },
          tag: {
            type: "text",
            analyzer: "simple"
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
    }
  end

  def document(object)
    object.as_json(
      root: false,
      only: [
        :id, :expected_number_of_chapters, :created_at, :updated_at,
        :major_version, :minor_version, :posted, :language_id, :restricted,
        :title, :summary, :notes, :word_count, :hidden_by_admin, :revised_at,
        :title_to_sort_on, :backdate, :endnotes,
        :imported_from_url, :complete, :work_skin_id, :in_anon_collection,
        :in_unrevealed_collection,
      ],
      methods: [
        :authors_to_sort_on,
        :rating_ids,
        :warning_ids,
        :category_ids,
        :fandom_ids,
        :character_ids,
        :relationship_ids,
        :freeform_ids,
        :filter_ids,
        :tag,
        :pseud_ids,
        :user_ids,
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
    )
  end

end
