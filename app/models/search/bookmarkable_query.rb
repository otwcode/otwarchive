class BookmarkableQuery < Query
  include TaggableQuery

  attr_accessor :bookmark_query

  # Rather than compute this information twice, we rely on the BookmarkQuery
  # class to calculate information about sorting.
  delegate :sort_column, :sort_direction,
           to: :bookmark_query

  # The "klass" function here returns the class name used to load search
  # results. The BookmarkableQuery is unique among Query classes because it can
  # return objects from more than one table, so we need to use a special class
  # that can handle IDs of multiple types.
  def klass
    'BookmarkableDecorator'
  end

  def index_name
    BookmarkableIndexer.index_name
  end

  def document_type
    BookmarkableIndexer.document_type
  end

  # The BookmarkableQuery is unique among queries in that it depends wholly on
  # the BookmarkQuery for all of its options. So we have a slightly different
  # constructor.
  def initialize(bookmark_query)
    self.bookmark_query = bookmark_query
    @options = bookmark_query.options
  end

  # Combine the filters and queries for both the bookmark and the bookmarkable.
  def filtered_query
    make_bool(
      # All queries/filters/exclusion filters for the bookmark are wrapped in a
      # single has_child query by the bookmark_filter function:
      must: bookmark_filter,
      # We never sort by score, so we can always ignore the score on our
      # queries, grouping them together with our filters. (Note, however, that
      # the bookmark search can incorporate our score, so there is a
      # distinction between queries and filters -- just not in this function.)
      filter: make_list(queries, filters),
      must_not: exclusion_filters
    )
  end

  # Queries that apply only to the bookmarkable. Bookmark queries are handled
  # in filtered_query, and should not be included here.
  def queries
    @queries ||= make_list(
      general_query
    )
  end

  # Filters that apply only to the bookmarkable. Bookmark filters are handled
  # in filtered_query, and should not be included here.
  def filters
    @filters ||= make_list(
      complete_filter,
      language_filter,
      filter_id_filter,
      named_tag_inclusion_filter,
      date_filter
    )
  end

  # Exclusion filters that apply only to the bookmarkable. Exclusion filters
  # for the bookmark are handled in filtered_query, and should not be included
  # here.
  def exclusion_filters
    @exclusion_filters ||= make_list(
      unposted_filter,
      hidden_filter,
      restricted_filter,
      tag_exclusion_filter,
      named_tag_exclusion_filter
    )
  end

  ####################
  # QUERIES
  ####################

  def general_query
    return nil if bookmarkable_query_text.blank?

    { query_string: { query: bookmarkable_query_text, default_operator: "AND" } }
  end

  def bookmarkable_query_text
    query_text = (options[:bookmarkable_query] || "").dup
    escape_slashes(query_text.strip)
  end

  ####################
  # SORTING AND AGGREGATIONS
  ####################

  # When sorting by bookmarkable date, we use the revised_at field to order the
  # results. When sorting by created_at, we use _score to sort (because the
  # only way to sort by a child's fields is to store the value in the _score
  # field and sort by score).
  def sort
    if sort_column == "bookmarkable_date"
      sort_hash = { revised_at: { order: sort_direction, unmapped_type: "date" } }
    else
      sort_hash = { _score: { order: sort_direction } }
    end

    [sort_hash, { sort_id: { order: sort_direction } }]
  end

  # Define the aggregations for just the bookmarkable. This is combined with
  # the bookmark's aggregations below.
  def bookmarkable_aggregations
    aggs = {}

    if bookmark_query.facet_tags?
      %w[rating archive_warning category fandom character relationship freeform].each do |facet_type|
        aggs[facet_type] = {
          terms: {
            field: "#{facet_type}_ids"
          }
        }
      end
    end

    aggs
  end

  # Combine the bookmarkable aggregations with the bookmark aggregations from
  # the bookmark query.
  def aggregations
    aggs = bookmarkable_aggregations

    bookmark_aggregations = bookmark_query.bookmark_aggregations
    if bookmark_aggregations.present?
      aggs[:bookmarks] = {
        # Aggregate on our child bookmarks.
        children: { type: "bookmark" },
        aggs: {
          filtered_bookmarks: {
            filter: bookmark_bool,
            aggs: bookmark_aggregations
          }
        }
      }
    end

    { aggs: aggs } if aggs.present?
  end

  ####################
  # BOOKMARKS
  ####################

  # Create a single has_child query with ALL of the child's queries and filters
  # included. In order to avoid issues with multiple bookmarks combining to
  # create an (incorrect) bookmarkable match, there MUST be exactly one
  # has_child query. (Plus, it probably makes it faster.)
  def bookmark_filter
    bool = bookmark_bool

    # If we're sorting by created_at, we actually need to fetch the bookmarks'
    # created_at as the score of this query, so that we can sort by score (and
    # therefore by the bookmarks' created_at).
    bool = field_value_score("created_at", bool) if sort_column == "created_at"

    {
      has_child: {
        type: "bookmark",
        score_mode: "max",
        query: bool,
        inner_hits: {
          size: inner_hits_size,
          sort: { created_at: { order: "desc", unmapped_type: "date" } }
        }
      }
    }
  end

  # The bool used in the has_child query and to filter the bookmark
  # aggregations. Contains all of the constraints on bookmarks, and no
  # constraints on bookmarkables.
  def bookmark_bool
    make_bool(
      must: bookmark_query.queries,
      filter: bookmark_query.filters,
      must_not: bookmark_query.exclusion_filters
    )
  end

  ####################
  # FILTERS
  ####################

  def complete_filter
    term_filter(:complete, 'true') if options[:complete].present?
  end

  def language_filter
    term_filter(:"language_id.keyword", options[:language_id]) if options[:language_id].present?
  end

  def filter_id_filter
    if filter_ids.present?
      filter_ids.map { |filter_id| term_filter(:filter_ids, filter_id) }
    end
  end

  # The date filter on the bookmarkable (i.e. when the bookmarkable was last
  # updated).
  def date_filter
    if options[:bookmarkable_date].present?
      { range: { revised_at: SearchRange.parsed(options[:bookmarkable_date]) } }
    end
  end

  # Exclude drafts from bookmarkable search results.
  # Note that this is used as an exclusion filter, not an inclusion filter, so
  # the boolean is flipped from the way you might expect.
  def unposted_filter
    term_filter(:posted, 'false')
  end

  # Exclude items hidden by admin from bookmarkable search results.
  # Note that this is used as an exclusion filter, not an inclusion filter, so
  # the boolean is flipped from the way you might expect.
  def hidden_filter
    term_filter(:hidden_by_admin, 'true')
  end

  # Exclude restricted works/series when the user isn't logged in.
  # Note that this is used as an exclusion filter, not an inclusion filter, so
  # the boolean is flipped from the way you might expect.
  def restricted_filter
    term_filter(:restricted, 'true') unless include_restricted?
  end

  def tag_exclusion_filter
    if exclusion_ids.present?
      terms_filter(:filter_ids, exclusion_ids)
    end
  end

  # This filter is used to restrict our results to only include bookmarkables
  # whose "tag" text matches all of the tag names in included_tag_names. This
  # is useful when the user enters a non-existent tag, which would be discarded
  # by the TaggableQuery.filter_ids function.
  def named_tag_inclusion_filter
    return if included_tag_names.blank?
    match_filter(:tag, included_tag_names.join(" "))
  end

  # This set of filters is used to prevent us from matching any bookmarkables
  # whose "tag" text matches one of the passed-in tag names. This is useful
  # when the user enters a non-existent tag, which would be discarded by the
  # TaggableQuery.exclusion_ids function.
  #
  # Note that we separate these into different filters to get the logic of tag
  # exclusion right: if we're excluding "A B" and "C D", we want the query to
  # be "not(A and B) and not(C and D)", which can't be accomplished in a single
  # match query.
  def named_tag_exclusion_filter
    excluded_tag_names.map do |tag_name|
      match_filter(:tag, tag_name)
    end
  end

  ####################
  # HELPERS
  ####################

  # The number of bookmarks to return with each bookmarkable.
  def inner_hits_size
    ArchiveConfig.NUMBER_OF_BOOKMARKS_SHOWN_PER_BOOKMARKABLE || 5
  end

  def include_restricted?
    # Use fetch instead of || here to make sure that we don't accidentally
    # override a deliberate choice not to show restricted bookmarks.
    options.fetch(:show_restricted, User.current_user.present?)
  end
end
