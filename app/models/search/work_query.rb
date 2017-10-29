class WorkQuery < Query
  include TaggableQuery

  def klass
    'Work'
  end

  def index_name
    WorkIndexer.index_name
  end

  def document_type
    WorkIndexer.document_type
  end

  # Combine the available filters
  def filters
    add_owner
    @filters ||= (
      visibility_filters +
      work_filters +
      creator_filters +
      collection_filters +
      tag_filters +
      range_filters
    ).flatten.compact
  end

  def exclusion_filters
    tag_exclusion_filter.compact if tag_exclusion_filter
  end

  # Combine the available queries
  # In this case, name is the only text field
  def queries
    @queries = [general_query] unless general_query.blank? #if options[:q] || options[:query].present?
  end

  def add_owner
    owner = options[:works_parent]
    field = case owner
            when Tag
              :filter_ids
            when Pseud
              :pseud_ids
            when User
              :user_ids
            when Collection
              :collection_ids
            end
    return unless field.present?
    options[field] ||= []
    options[field] << owner.id
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

  def creator_filters
    [user_filter, pseud_filter]
  end

  def collection_filters
    [collection_filter]
  end

  def tag_filters
    [
      filter_id_filter
    ]
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
    term_filter(:posted, 'true')
  end

  def hidden_filter
    term_filter(:hidden_by_admin, 'false')
  end

  def restricted_filter
    term_filter(:restricted, 'false') unless include_restricted?
  end

  def unrevealed_filter
    term_filter(:in_unrevealed_collection, 'false') unless include_unrevealed?
  end

  def anon_filter
    term_filter(:in_anon_collection, 'false') unless include_anon?
  end

  def complete_filter
    term_filter(:complete, 'true') if %w(true 1).include?(options[:complete].to_s)
  end

  def single_chapter_filter
    term_filter(:expected_number_of_chapters, 1) if options[:single_chapter].present?
  end

  def language_filter
    term_filter(:language_id, options[:language_id]) if options[:language_id].present?
  end

  def crossover_filter
    term_filter(:crossover, include_crossovers) if include_crossovers.present?
  end

  def type_filter
    terms_filter(:work_type, options[:work_types]) if options[:work_types]
  end

  def user_filter
    terms_filter(:user_ids, options[:user_ids]) if options[:user_ids].present?
  end

  def pseud_filter
    terms_filter(:pseud_ids, pseud_ids) if pseud_ids.present?
  end

  def collection_filter
    terms_filter(:collection_ids, options[:collection_ids]) if options[:collection_ids].present?
  end

  def filter_id_filter
    if filter_ids.present?
      filter_ids.map { |filter_id| term_filter(:filter_ids, filter_id) }
    end
  end

  def tag_exclusion_filter
    if exclusion_ids.present?
      exclusion_ids.map { |exclusion_id| term_filter(:filter_ids, exclusion_id) }
    end
  end

  ####################
  # QUERIES
  ####################

  # Search for a tag by name
  def general_query
    input = (options[:q] || options[:query] || "").dup
    query = generate_search_text(input)

    return { query_string: { query: query, default_operator: "AND" } } unless query.blank?
  end

  def generate_search_text(query = '')
    search_text = query
    [:title, :creators].each do |field|
      search_text << split_query_text_words(field, options[field])
    end
    search_text << split_query_text_phrases(:tag, options[:tag])
    if self.options[:collection_ids].blank? && options[:collected]
      search_text << " collection_ids:*"
    end
    escape_slashes(search_text.strip)
  end

  def sort
    column = options[:sort_column].present? ? options[:sort_column] : 'revised_at'
    direction = options[:sort_direction].present? ? options[:sort_direction] : 'desc'
    sort_hash = { column => { order: direction } }

    if column == 'revised_at'
      sort_hash[column][:unmapped_type] = 'date'
    end

    sort_hash
  end

  def aggregations
    aggs = {}
    if facet_collections?
      aggs[:collections] = { terms: { field: 'collection_ids' } }
    end

    if facet_tags?
      %w(rating warning category fandom character relationship freeform).each do |facet_type|
        aggs[facet_type] = { terms: { field: "#{facet_type}_ids" } }
      end
    end

    { aggs: aggs }
  end

  ####################
  # HELPERS
  ####################

  def facet_tags?
    options[:faceted]
  end

  def facet_collections?
    options[:collected]
  end

  def include_restricted?
    User.current_user.present? || options[:show_restricted]
  end

  def include_unrevealed?
    options[:collection_ids].present?
  end

  def include_anon?
    options[:user_ids].blank? && pseud_ids.blank?
  end

  def include_crossovers
    return unless options[:crossover].present?
    if %w(1 true T).include? options[:crossover].to_s
      'true'
    else
      'false'
    end
  end

  def pseud_ids
    options[:pseud_ids]
  end
end
