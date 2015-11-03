class TagQuery < Query

  def index_name
    TagIndexer.index_name
  end

  def document_type
    TagIndexer.document_type
  end

  def filters
    [type_filter, canonical_filter].compact
  end

  def queries
    [name_query].compact
  end

  ################
  # FILTERS
  ################

  def type_filter
    { term: { tag_type: options[:tag_type] } } if options[:tag_type]
  end

  def canonical_filter
    { term: { canonical: 'T' } } if options[:canonical]
  end

  ################
  # QUERIES
  ################

  def name_query
    { match: { name: options[:name] } } if options[:name]
  end

end
