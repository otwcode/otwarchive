class BookmarkQuery < Query
  include TaggableQuery

  attr_accessor :bookmarkable_query

  def klass
    'Bookmark'
  end

  def index_name
    BookmarkIndexer.index_name
  end

  def document_type
    BookmarkIndexer.document_type
  end

  # Load the options and create the linked BookmarkableQuery class (which is
  # used to generate all of our parent filters).
  def initialize(options = {})
    @options = HashWithIndifferentAccess.new(options)
    add_owner
    self.bookmarkable_query = BookmarkableQuery.new(self)
  end

  # After the initial search, run an additional query to get work/series tag filters
  # Elasticsearch doesn't support parent aggregations, and doing the main query on the parents
  # limits searching and sorting on the bookmarks themselves
  # Hopefully someday they'll fix this and we can get the data from a single query
  def search_results
    response = search
    if response['aggregations']
      response['aggregations'].merge!(bookmarkable_query.aggregation_results)
    end
    QueryResult.new(klass, response, options.slice(:page, :per_page))
  end

  # Combine the filters on the bookmark with the filters on the bookmarkable.
  def filters
    @filters ||= [
      bookmark_filters,
      bookmarkable_filter
    ].flatten.compact
  end

  # Combine the exclusion filters on the bookmark with the exclusion filters on
  # the bookmarkable.
  def exclusion_filters
    @exclusion_filters ||= [
      bookmark_exclusion_filters,
      bookmarkable_exclusion_filter
    ].flatten.compact
  end

  def add_owner
    owner = options[:parent]
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
  # QUERIES
  ####################

  # Instead of doing a standard query, which would only match bookmark fields
  # we'll make this a should query that will try to match either the bookmark
  # or its parent
  # TODO This isn't right, since it requires all of the fields to be on one or
  # the other (and, in particular, can't handle tags on the parent with a
  # specified bookmarker on the child).
  def query
    if query_term.present?
      @query ||= make_bool(should: [general_query, parent_query])
    end
  end

  def general_query
    { query_string: { query: query_term, default_operator: "AND" } }
  end

  def parent_query
    {
      has_parent: {
        parent_type: "bookmarkable",
        score: true, # include the score from the bookmarkable
        query: {
          query_string: {
            query: query_term,
            default_operator: "AND"
          }
        }
      }
    }
  end

  def query_term
    input = (options[:q] || options[:query] || "").dup
    generate_search_text(input)
  end

  def generate_search_text(query = '')
    search_text = query
    [:bookmarker, :notes].each do |field|
      search_text << split_query_text_words(field, options[field])
    end
    search_text << split_query_text_phrases(:tag, options[:tag])
    escape_slashes(search_text.strip)
  end

  ####################
  # SORTING AND AGGREGATIONS
  ####################

  def sort
    column = options[:sort_column].present? ? options[:sort_column] : 'created_at'
    direction = options[:sort_direction].present? ? options[:sort_direction] : 'desc'
    sort_hash = { column => { order: direction } }

    if %w(created_at bookmarkable_date).include?(column)
      sort_hash[column][:unmapped_type] = 'date'
    end

    sort_hash
  end

  def aggregations
    aggs = {}
    if facet_collections?
      aggs[:collections] = { terms: { field: 'collection_ids' } }
    end

    if facet_tags?
      aggs[:tag] = { terms: { field: "tag_ids" } }
    end

    { aggs: aggs }
  end

  ####################
  # GROUPS OF FILTERS
  ####################

  # Filters that apply only to the bookmark. These are must/and filters,
  # meaning that all of them are required to occur in all bookmarks.
  def bookmark_filters
    @bookmark_filters ||= [
      privacy_filter,
      hidden_filter,
      bookmarks_only_filter,
      pseud_filter,
      user_filter,
      rec_filter,
      notes_filter,
      tags_filter,
      collections_filter,
      type_filter,
      date_filter
    ].compact
  end

  # Exclusion filters that apply only to the bookmark. These are must_not/not
  # filters, meaning that none of them are allowed to occur in any search
  # results. DO NOT INCLUDE FILTERS ON THE BOOKMARKABLE HERE. If you do, this
  # may cause an infinite loop.
  def bookmark_exclusion_filters
    @bookmark_exclusion_filters ||= [
      tag_exclusion_filter
    ].compact
  end

  # Wrap all of the must/and filters on the bookmarkable into a single
  # has_parent query. (The more has_parent queries we have, the slower our
  # search will be.)
  def bookmarkable_filter
    return if bookmarkable_query.bookmarkable_filters.blank?

    @bookmarkable_filter ||= {
      has_parent: {
        parent_type: "bookmarkable",
        query: make_bool(
          must: bookmarkable_query.bookmarkable_filters
        )
      }
    }
  end

  # Wrap all of the must_not/not filters on the bookmarkable into a single
  # has_parent query. Note that we wrap them in a should/or query because if
  # any of the parent queries return true, we want to return false. (De
  # Morgan's Law.)
  def bookmarkable_exclusion_filter
    return if bookmarkable_query.bookmarkable_exclusion_filters.blank?

    @bookmarkable_exclusion_filter ||= {
      has_parent: {
        parent_type: "bookmarkable",
        query: make_bool(
          should: bookmarkable_query.bookmarkable_exclusion_filters
        )
      }
    }
  end

  ####################
  # FILTERS
  ####################

  def privacy_filter
    term_filter(:private, 'false') unless include_private?
  end

  def hidden_filter
    term_filter(:hidden_by_admin, 'false')
  end

  def rec_filter
    term_filter(:rec, 'true') if %w(1 true).include?(options[:rec].to_s)
  end

  def notes_filter
    term_filter(:with_notes, 'true') if %w(1 true).include?(options[:with_notes].to_s)
  end

  def type_filter
    term_filter(:bookmarkable_type, options[:bookmarkable_type].gsub(" ", "")) if options[:bookmarkable_type].present?
  end

  # The date filter on the bookmark (i.e. when the bookmark was created).
  def date_filter
    if options[:date].present?
      { range: { created_at: Search.range_to_search(options[:date]) } }
    end
  end

  def pseud_filter
    if options[:pseud_ids].present?
      terms_filter(:pseud_id, options[:pseud_ids].flatten.uniq)
    end
  end

  def user_filter
    return unless options[:user_ids].present?
    options[:user_ids].flatten.uniq.map { |user_id| term_filter(:user_id, user_id) }
  end

  def tags_filter
    if options[:tag_ids].present?
      options[:tag_ids].map { |tag_id| term_filter(:tag_ids, tag_id) }
    end
  end

  def collections_filter
    terms_filter(:collection_ids, options[:collection_ids]) if options[:collection_ids].present?
  end

  def tag_exclusion_filter
    if exclusion_ids.present?
      terms_filter(:tag_ids, exclusion_ids)
    end
  end

  # We don't want to accidentally return Bookmarkable documents when we're
  # doing a search for Bookmarks. So we should only include documents that are
  # marked as "bookmark" in their bookmarkable_join field.
  def bookmarks_only_filter
    term_filter(:bookmarkable_join, "bookmark")
  end

  ####################
  # HELPERS
  ####################

  def facet_tags?
    options[:faceted]
  end

  def facet_collections?
    false
  end

  def include_private?
    # Use fetch instead of || here to make sure that we don't accidentally
    # override a deliberate choice not to show private bookmarks.
    options.fetch(:show_private,
                  User.current_user.is_a?(User) &&
                  user_ids.include?(User.current_user.id))
  end

  def user_ids
    user_ids = []
    if options[:user_ids].present?
      user_ids += options[:user_ids].map(&:to_i)
    end
    if options[:pseud_ids].present?
      user_ids += Pseud.where(id: options[:pseud_ids]).pluck(:user_id)
    end
    user_ids
  end
end
