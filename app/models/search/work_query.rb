class WorkQuery < Query

  def klass
    'Work'
  end

  [ :fandom_ids,
    :rating_ids,
    :category_ids,
    :warning_ids,
    :character_names,
    :character_ids,
    :relationship_names,
    :relationship_ids,
    :freeform_names,
    :freeform_ids,
    :other_tag_names,
    :excluded_tag_names,
    :language_id,
    :complete,
    :query].each do |filterable|
      define_method(filterable) { options[filterable] }
    end

  def index_name
    WorkIndexer.index_name
  end

  def document_type
    WorkIndexer.document_type
  end

  # Combine the available filters
  def filters
    process_owner
    @filters ||= (
      visibility_filters +
      work_filters +
      pseud_filters +
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

  def process_owner
    return unless (parent = options[:works_parent]).present?
    case parent
    when Tag 
      options[:filter_ids] ||= []
      options[:filter_ids] << parent.id
    when Pseud 
    when User 
    end
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
    { term: { complete: 'T' } } if options[:complete].present? && %w(true 1).include?(options[:complete].to_s)
  end

  def single_chapter_filter
    { term: { expected_number_of_chapters: 1 } } if options[:single_chapter].present?
  end

  def language_filter
    { term: { language_id: options[:language_id] } } if options[:language_id].present?
  end
  
  def crossover_filter
    { term: { crossover: include_crossovers } } if include_crossovers.present?
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

  def tag_exclusion_filter
    { terms: { filter_ids: exclusion_ids } } if exclusion_ids.present?
  end

  ####################
  # QUERIES
  ####################

  # Search for a tag by name
  def general_query
    { query_string: { query: options[:q] || options[:query] } }
  end

  def sort
    column = options[:sort_column] || 'revised_at'
    direction = options[:sort_direction] || 'desc'
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
    false
  end

  def include_anon?
    pseud_ids.blank?
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

  ###############
  # SORTING
  ###############

    SORT_OPTIONS = [
    ['Author', 'authors_to_sort_on'],
    ['Title', 'title_to_sort_on'],
    ['Date Posted', 'created_at'],
    ['Date Updated', 'revised_at'],
    ['Word Count', 'word_count'],
    ['Hits', 'hits'],
    ['Kudos', 'kudos_count'],
    ['Comments', 'comments_count'],
    ['Bookmarks', 'bookmarks_count']
  ]
  
  def sort_options
    SORT_OPTIONS
  end
  
  def sort_values
    sort_options.map{ |option| option.last }
  end

  def sort_column
    options[:sort_column] || 'revised_at'
  end
  
  # extract the pretty name
  def name_for_sort_column(sort_column)
    Hash[SORT_OPTIONS.collect {|v| [ v[1], v[0] ]}][sort_column]
  end
  
  def sort_direction(sort_column)
    if %w(authors_to_sort_on title_to_sort_on).include?(sort_column)
      'asc'
    else
      'desc'
    end
  end

end