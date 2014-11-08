class WorkQuery < Query

  def index_name
    WorkIndexer.index_name
  end

  def document_type
    WorkIndexer.document_type
  end

  # Combine the available filters
  def filters
    @filters ||= (
      visibility_filters +
      work_filters +
      pseud_filters +
      collection_filters +
      tag_filters +
      range_filters
    ).compact
  end

  # Combine the available queries
  # In this case, name is the only text field
  def queries
    @queries = [general_query] if options[:q]
  end

  ####################
  # GROUPS OF FILTERS
  ####################

  def visibility_filters
    [
      posted_filter,
      hidden_filter,
      restricted_filter,
      unrevealed_filter,
      anon_filter
    ]
  end

  def work_filters
    [
      complete_filter,
      single_chapter_filter,
      language_filter,
      crossover_filter,
      type_filter
    ]
  end

  def pseud_filters
    [pseud_filter]
  end

  def collection_filters
    [collection_filter]
  end

  def tag_filters
    [filter_id_filter]
  end

  def range_filters
    ranges = []
    [:word_count, :hits, :kudos_count, :comments_count, :bookmarks_count, :revised_at].each do |countable|
      if options[countable].present?
        ranges << { range: { countable => Search.range_to_search(options[countable]) } }
      end
    end
    ranges
  end

  ####################
  # FILTERS
  ####################

  def posted_filter
    { term: { posted: 'T' } }
  end

  def hidden_filter
    { term: { hidden_by_admin: 'F' } }
  end

  def restricted_filter
    { term: { restricted: 'F' } } unless include_restricted?
  end

  def unrevealed_filter
    { term: { in_unrevealed_collection: 'F' } } unless include_unrevealed?
  end

  def anon_filter
    { term: { in_anon_collection: 'F' } } unless include_anon?
  end

  def complete_filter
    { term: { complete: 'T' } } if options[:complete]
  end

  def single_chapter_filter
    { term: { expected_number_of_chapters: 1 } } if options[:single_chapter]
  end

  def language_filter
    { term: { language_id: options[:language_id] } } if options[:language_id]
  end
  
  def crossover_filter
    { term: { crossover: options[:crossover] } } if options[:crossover]
  end
  
  def type_filter
    { terms: { work_type: options[:work_types] } } if options[:work_types]
  end

  def pseud_filter
    { terms: { pseud_ids: pseud_ids } } if pseud_ids.present?
  end

  def collection_filter
    if options[:collection_ids].present?
      { terms: { collection_ids: options[:collection_ids] } }
    end
  end

  def filter_id_filter
    { terms: { filter_ids: filter_ids, execution: 'and' } } if filter_ids.present?
  end

  ####################
  # QUERIES
  ####################

  # Search for a tag by name
  def general_query
    { query_string: { query: options[:q] } }
  end

  ####################
  # HELPERS
  ####################

  def include_restricted?
    User.current_user.present?
  end

  def include_unrevealed?
    false
  end

  def include_anon?
    pseud_ids.blank?
  end

  def pseud_ids
    return @pseud_ids if @pseud_ids.present?
    @pseud_ids = options[:pseud_ids] || []
    if options[:user_id].present?
      @pseud_ids += Pseud.where(user_id: options[:user_id]).value_of(:id)
    end
    @pseud_ids.uniq
  end

  def filter_ids
    return @filter_ids if @filter_ids.present?
    @filter_ids = options[:filter_ids] || []
    %w(fandom rating warning category character relationship freeform).each do |tag_type|
      @filter_ids += options["#{tag_type}_ids".to_sym] || []
    end
    @filter_ids.uniq
  end

end