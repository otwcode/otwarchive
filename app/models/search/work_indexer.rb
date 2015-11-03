class WorkIndexer < Indexer

  def self.klass
    'Work'
  end

  def self.mapping
    {
      'work' => {
        properties: {
          title: {
            type: 'string',
            analyzer: 'simple',
          },
          creators: {
            type: 'string',
            analyzer: 'simple',
            index_name: 'creator'
          },
          tag: {
            type: 'string',
            analyzer: 'simple'
          },
          authors_to_sort_on: {
            type: 'string',
            index: 'not_analyzed'
          },
          title_to_sort_on: {
            type: 'string',
            index: 'not_analyzed'
          },
          imported_from_url: {
            type: 'string',
            index: 'not_analyzed'
          },
          work_types: {
            type: 'string',
            index_name: 'work_type',
            index: 'not_analyzed',
          }
        }
      }
    }
  end

  def document(object)
    object.as_json(
      root: false,
      except: [
        :delta, :summary_sanitizer_version, :notes_sanitizer_version,
        :endnotes_sanitizer_version, :hit_count_old, :last_visitor_old],
      methods: [
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
