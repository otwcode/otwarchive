class WorkQuery < Query

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
    ).compact
  end

  def exclusion_filters
    [tag_exclusion_filter].compact
  end

  # Combine the available queries
  # In this case, name is the only text field
  def queries
    @queries = [general_query] if options[:q] || options[:query].present?
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
    term_filter(:posted, 'T')
  end

  def hidden_filter
    term_filter(:hidden_by_admin, 'F')
  end

  def restricted_filter
    term_filter(:restricted, 'F') unless include_restricted?
  end

  def unrevealed_filter
    term_filter(:in_unrevealed_collection, 'F') unless include_unrevealed?
  end

  def anon_filter
    term_filter(:in_anon_collection, 'F') unless include_anon?
  end

  def complete_filter
    term_filter(:complete, 'T') if %w(true 1).include?(options[:complete].to_s)
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
    terms_filter(:filter_ids, filter_ids, execution: 'and') if filter_ids.present?
  end

  def tag_exclusion_filter
    terms_filter(:filter_ids, exclusion_ids) if exclusion_ids.present?
  end

  ####################
  # QUERIES
  ####################

  # Search for a tag by name
  def general_query
    { query_string: { query: options[:q] || options[:query] } }
  end

  def sort
    column = options[:sort_column].present? ? options[:sort_column] : 'revised_at'
    direction = options[:sort_direction].present? ? options[:sort_direction] : 'desc'
    { column => { order: direction } }
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
    true
  end

  def facet_collections?
    false
  end

  def include_restricted?
    User.current_user.present?
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
      'T'
    else
      'F'
    end
  end

  def pseud_ids
    options[:pseud_ids]
  end

  def filter_ids
    return @filter_ids if @filter_ids.present?
    @filter_ids = options[:filter_ids] || []
    %w(fandom rating warning category character relationship freeform).each do |tag_type|
      if options["#{tag_type}_ids".to_sym].present?
        @filter_ids += options["#{tag_type}_ids".to_sym]
      end
    end
    @filter_ids += named_tags
    @filter_ids.uniq
  end

  # Get the ids for tags passed in by name
  def named_tags
    tag_ids = []
    %w(fandom character relationship freeform other_tag).each do |tag_type|
      tag_names_key = "#{tag_type}_names".to_sym
      if options[tag_names_key].present?
        names = options[tag_names_key].split(",")
        tags = Tag.where(name: names, canonical: true)
        unless tags.empty?
          tag_ids += tags.map{ |tag| tag.id }
        end
      end
    end
    tag_ids
  end

  def exclusion_ids
    return unless options[:excluded_tag_names]
    names = options[:excluded_tag_names].split(",")
    Tag.where(name: names, canonical: true).value_of(:id)
  end
  

end