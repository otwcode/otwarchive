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
    [collection_filter, fandom_filter].compact
  end

  def queries
    [general_query, name_query].compact
  end

  ###########
  # FILTERS
  ###########

  def collection_filter
    { term: { collection_ids: options[:collection_id] } } if options[:collection_id]
  end

  def fandom_filter
    if options[:fandom_ids]
      options[:fandom_ids].map do |fandom_id|
        { term: { "fandoms.id" => fandom_id } }
      end
    end
  end

  ###########
  # QUERIES
  ###########

  def general_query
    { query_string: { query: options[:query] } } if options[:query]
  end

  def name_query
    { match: { byline: escape_reserved_characters(options[:name]) } } if options[:name]
  end
end
