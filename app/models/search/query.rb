class Query

  attr_reader :options

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

  # Search query with filters
  def generated_query
    { query: { filtered: filtered_query } }
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
    { bool: { must: filters } } if filters.present?
  end

  # Boolean query
  def query_bool
    { bool: { must: queries } } if queries.present?
  end

  # Define specifics in subclasses
  
  def filters
  end

  def queries
  end

  def index_name
  end

  def document_type
  end

end