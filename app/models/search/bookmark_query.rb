class BookmarkQuery < Query
  include TaggableQuery

  def klass
    'Bookmark'
  end

  def index_name
    BookmarkIndexer.index_name
  end

  def document_type
    BookmarkIndexer.document_type
  end

  # After the initial search, run an additional query to get work/series tag filters
  # Elasticsearch doesn't support parent aggregations, and doing the main query on the parents
  # limits searching and sorting on the bookmarks themselves
  # Hopefully someday they'll fix this and we can get the data from a single query
  def search_results
    response = search
    if response['aggregations']
      response['aggregations'].merge!(BookmarkableQuery.filters_for_bookmarks(self))
    end
    QueryResult.new(klass, response, options.slice(:page, :per_page))
  end

  # Combine the available filters
  def filters
    add_owner
    @filters ||= (
      visibility_filters +
      bookmark_filters +
      bookmarkable_filters +
      range_filters
    ).flatten.compact
  end

  def exclusion_filters
    @exclusion_filters ||= tag_exclusion_filter
  end

  # Instead of doing a standard query, which would only match bookmark fields
  # we'll make this a should query that will try to match either the bookmark or its parent
  def should_query
    if query_term.present?
      @should_queries = parent_child_query
    end
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

  def parent_child_query
    [
      general_query,
      parent_query
    ]
  end

  def general_query
    { query_string: { query: query_term } }
  end

  def parent_query
    {
      has_parent: {
        parent_type: "bookmarkable",
        query: {
          query_string: {
            query: query_term
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

  def visibility_filters
    [
      privacy_filter,
      posted_filter,
      hidden_filter,
      hidden_parent_filter,
      restricted_filter
    ]
  end

  def bookmark_filters
    [
      pseud_filter,
      user_filter,
      rec_filter,
      notes_filter,
      tags_filter,
      collections_filter,
      type_filter
    ]
  end

  def bookmarkable_filters
    [
      complete_filter,
      language_filter,
      filter_id_filter
    ]
  end

  def range_filters
    ranges = []
    [:date, :bookmarkable_date].each do |countable|
      if options[countable].present?
        key = countable == :date ? :created_at : countable
        ranges << { range: { key => Search.range_to_search(options[countable]) } }
      end
    end
    ranges
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
    term_filter(:bookmarkable_type, options[:bookmarkable_type].gsub(" ", "")) if options[:bookmarkable_type]
  end

  def posted_filter
    parent_term_filter(:posted, 'true')
  end

  def hidden_parent_filter
    parent_term_filter(:hidden_by_admin, 'false')
  end

  def restricted_filter
    parent_term_filter(:restricted, 'false') unless include_restricted?
  end

  def complete_filter
    parent_term_filter(:complete, 'true') if options[:complete].present?
  end

  def language_filter
    parent_term_filter(:language_id, options[:language_id].to_i) if options[:language_id].present?
  end

  def pseud_filter
    if options[:pseud_ids].present?
      options[:pseud_ids].flatten.uniq.map { |pseud_id| term_filter(:pseud_id, pseud_id) }
    end
    # terms_filter(:pseud_id, options[:pseud_ids].flatten.uniq) if options[:pseud_ids].present?
  end

  def user_filter
    return unless options[:user_ids].present?
    options[:user_ids].flatten.uniq.map { |user_id| term_filter(:user_id, user_id) }
  end

  def filter_id_filter
    if filter_ids.present?
      filter_ids.map{ |filter_id| parent_term_filter(:filter_ids, filter_id) }
    end
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
      exclusion_ids.flatten.map { |exclusion_id|
        [
          parent_term_filter(:filter_ids, exclusion_id),
          term_filter(:tag_ids, exclusion_id)
        ]
      }.flatten
    end
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
    options[:show_private] ||
      User.current_user && user_ids.include?(User.current_user.id)
  end

  def include_restricted?
    options[:show_restricted] ||
      User.current_user.present?
  end

  def user_ids
    user_ids = []
    if options[:user_ids].present?
      user_ids += options[:user_ids].map(&:to_i)
    end
    if options[:pseud_ids].present?
      user_ids += Pseud.where(id: options[:pseud_id]).pluck(:user_id)
    end
    user_ids
  end

  def parent_term_filter(field, value, options={})
    {
      has_parent: {
        parent_type: "bookmarkable",
        query: {
          term: options.merge(field => value)
        }
      }
    }
  end

  def parent_terms_filter(field, value, options={})
    {
      has_parent: {
        parent_type: "bookmarkable",
        query: {
          terms: options.merge(field => value)
        }
      }
    }
  end
end
