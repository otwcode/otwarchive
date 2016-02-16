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
    query = BookmarkableQuery.new
    query.add_bookmark_filters(bookmark_query)
    query.aggregation_results
  end

  # Take the existing bookmark filters and flip them around
  # Simple term filters should now be child filters so they apply to the bookmarks
  # Parent filters should now be regular filters on the work/series
  def add_bookmark_filters(bookmark_query)
    @filters ||= []
    bookmark_filters = bookmark_query.generated_query[:query][:filtered][:filter][:bool][:must]
    bookmark_filters.each do |filter|
      if filter.has_key?(:term) || filter.has_key?(:terms)
        @filters << { has_child: { type: "bookmark", filter: filter } }
      elsif filter.has_key?(:has_parent)
        @filters << filter[:has_parent][:filter]
      end
    end
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

end
