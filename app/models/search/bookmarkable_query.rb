class BookmarkableQuery < Query
  attr_accessor :bookmark_query

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
    query.bookmark_query = bookmark_query
    query.add_bookmark_filters
    query.aggregation_results
  end

  # Take the existing bookmark filters and flip them around
  # Simple term filters should now be child filters so they apply to the bookmarks
  # Parent filters should now be regular filters on the work/series
  def add_bookmark_filters
    add_flipped_filters
    add_flipped_exclusion_filters
    add_flipped_query
    add_child_filters
  end

  def child_filters
    @child_filters ||= { include: [], exclude: [] }
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

  def add_flipped_filters
    return unless bookmark_query&.filters.present?
    @filters ||= []
    @filters += bookmark_query.filters.map { |filter| flipped_filter(filter) }.compact
  end

  def add_flipped_exclusion_filters
    return unless bookmark_query&.exclusion_filters.present?
    @exclusion_filters ||= []
    @exclusion_filters += bookmark_query.exclusion_filters.map { |filter| flipped_filter(filter, type: :exclusion) }.compact
  end

  def add_flipped_query
    shoulds = bookmark_query&.should_query
    if shoulds.present?
      @should_queries = shoulds.map { |q| flipped_query(q) }
    end
  end

  # Because a work or a series can have many bookmarks, we need to combine
  # the child queries into one bool query so that we don't, eg, leak private bookmark data
  def flipped_filter(filter, options = {})
    if filter.key?(:term) || filter.key?(:terms)
      key = options[:type] == :exclusion ? :exclude : :include
      child_filters[key] << filter
      return nil
    elsif filter.key?(:has_parent)
      filter[:has_parent][:query]
    end
  end

  def flipped_query(q)
    if q.key?(:query_string) || q.key?(:simple_query_string)
      q
    elsif q.key?(:has_parent)
      child_query = q[:has_parent]&.merge(type: "bookmark")
      child_query.delete(:parent_type)
      { has_child: child_query }
    end
  end

  # Combine include and exclude child filters into one query so they apply to the same bookmarks
  def add_child_filters
    bool = {}
    bool[:must] = child_filters[:include] if child_filters[:include].present?
    bool[:must_not] = child_filters[:exclude] if child_filters[:exclude].present?
    unless bool.empty?
      has_child_query = {
        has_child: {
          type: 'bookmark',
          query: {
            bool: bool
          }
        }
      }
      @filters << has_child_query
    end
  end
end
