class BookmarkableQuery < Query
  def klass
    'Bookmarkable'
  end

  def index_name
    BookmarkableIndexer.index_name
  end

  def document_type
    BookmarkableIndexer.document_type
  end

  # Use an existing bookmark query to get aggregations on the parent objects
  # Elasticsearch doesn't let you do parent aggregations directly
  def self.filters_for_bookmarks(bookmark_query)
    query = BookmarkableQuery.new(per_page: 0)
    query.add_bookmark_filters(bookmark_query)
    query.aggregation_results
  end

  # Take the existing bookmark filters and flip them around
  # Simple term filters should now be child filters so they apply to the bookmarks
  # Parent filters should now be regular filters on the work/series
  def add_bookmark_filters(bookmark_query)
    add_flipped_filters(bookmark_query)
    add_flipped_exclusion_filters(bookmark_query)
    add_flipped_query(bookmark_query)
  end

  # Do a regular search and return only the aggregations
  def aggregation_results
    response = search
    response['aggregations']
  end

  # Define the aggregations for the search
  # In this case, the various tag fields
  def aggregations
    aggs = {}
    %w(rating warning category fandom character relationship freeform).each do |facet_type|
      aggs[facet_type] = { terms: { field: "#{facet_type}_ids" } }
    end
    { aggs: aggs }
  end

  private

  def add_flipped_filters(bookmark_query)
    if bookmark_query.filters.present?
      @filters ||= []
      bookmark_query.filters.each do |filter|
        @filters << flipped_filter(filter)
      end
    end
  end

  def add_flipped_exclusion_filters(bookmark_query)
    if bookmark_query.exclusion_filters.present?
      @exclusion_filters ||= []
      bookmark_query.exclusion_filters.each do |filter|
        @exclusion_filters << flipped_filter(filter)
      end
    end
  end

  def add_flipped_query(bookmark_query)
    shoulds = bookmark_query.should_query
    if shoulds.present?
      @should_queries = shoulds.map { |q| flipped_query(q) }
    end
  end

  def flipped_filter(filter)
    if filter.key?(:term) || filter.key?(:terms)
      { has_child: { type: "bookmark", query: filter } }
    elsif filter.key?(:has_parent)
      filter[:has_parent][:query]
    end
  end

  def flipped_query(q)
    if q.key?(:query_string)
      q
    elsif q.key?(:has_parent)
      { has_child: q[:has_parent]&.merge(type: "bookmark") }
    end
  end

end
