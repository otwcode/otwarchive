class PseudQuery < Query

  def klass
    'Pseud'
  end

  def index_name
    PseudIndexer.index_name
  end

  def document_type
    PseudIndexer.document_type
  end

  def filters
    [collection_filter].compact
  end

  def queries
    [general_query].compact
  end

  ###########
  # FILTERS
  ###########

  def collection_filter
    { term: { collection_ids: options[:collection_id] } } if options[:collection_id]
  end

  ###########
  # QUERIES
  ###########

  def general_query
    { query_string: { query: options[:query] } } if options[:query]
  end

end
