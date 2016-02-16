class Query

  attr_reader :options

  # Options: page, per_page, 
  def initialize(options={})
    @options = options
  end

  def search
    $elasticsearch.search(
      index: index_name,
      type: document_type,
      body: generated_query
    )
  end

  def search_results
    response = search
    QueryResult.new(klass, response, options.slice(:page, :per_page))
  end

  # Sort by relevance by default, override in subclasses as necessary
  def sort
    { "_score" => { order: "desc" }}
  end

  # Search query with filters
  def generated_query
    q = { 
      query: { filtered: filtered_query },
      size: per_page,
      from: pagination_offset,
      sort: sort
    }
    if aggregations.present?
      q.merge!(aggregations)
    end
    q
  end

  # Combine the filters and queries
  # Don't include empty conditions, since those will affect results
  def filtered_query
    filtered_query = {}
    filtered_query[:filter] = filter_bool if filter_bool.present?
    filtered_query[:query] = query_bool if query_bool.present?
    filtered_query
  end

  # Boolean filter
  def filter_bool
    return unless filters.present?
    bool = { bool: { must: filters } }
    if exclusion_filters.present?
      bool[:bool].merge!(must_not: exclusion_filters)
    end
    bool
  end

  # Boolean query
  def query_bool
    { bool: { must: queries } } if queries.present?
  end

  # Define specifics in subclasses
  
  def filters
    @filters
  end

  def term_filter(field, value, options={})
    { term: options.merge(field => value) }
  end

  def terms_filter(field, value, options={})
    { terms: options.merge(field => value) }
  end

  def exclusion_filters
  end

  def queries
  end

  def aggregations
  end

  def index_name
  end

  def document_type
  end

  def per_page
    options[:per_page] || 20
  end

  def pagination_offset
    page = options[:page] || 1
    (page * per_page) - per_page
  end

end