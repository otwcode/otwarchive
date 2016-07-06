class BookmarkQuery < Query
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
    response['aggregations'].merge!(BookmarkableQuery.filters_for_bookmarks(self))
    QueryResult.new(klass, response, options.slice(:page, :per_page))
  end

  # Combine the available filters
  def filters
    add_owner
    @filters ||= (
      visibility_filters +
      bookmark_filters +
      bookmarkable_filters
    ).flatten.compact
  end

  def queries
    @queries = [general_query] if options[:q] || options[:query].present?
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

  # Search for a tag by name
  def general_query
    { query_string: { query: options[:q] || options[:query] } }
  end

  def sort
    column = options[:sort_column].present? ? options[:sort_column] : 'created_at'
    direction = options[:sort_direction].present? ? options[:sort_direction] : 'desc'
    { column => { order: direction } }
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
      collections_filter
    ]
  end

  def bookmarkable_filters
    [
      complete_filter,
      language_filter,
      filter_id_filter
    ]
  end

  ####################
  # FILTERS
  ####################

  def privacy_filter
    term_filter(:private, 'F') unless include_private?
  end

  def hidden_filter
    term_filter(:hidden_by_admin, 'F')
  end

  def rec_filter
    term_filter(:rec, 'T') if %w(1 true).include?(options[:rec].to_s)
  end

  def notes_filter
    term_filter(:with_notes, 'T') if %w(1 true).include?(options[:with_notes].to_s)
  end

  def type_filter
    term_filter(:bookmarkable_type, options[:bookmarkable_type].gsub(" ", "").downcase) if options[:bookmarkable_type]
  end

  def posted_filter
    parent_term_filter(:posted, 'T')
  end

  def hidden_parent_filter
    parent_term_filter(:hidden_by_admin, 'F')
  end

  def restricted_filter
    parent_term_filter(:restricted, 'F') unless include_restricted?
  end

  def complete_filter
    parent_term_filter(:complete, 'T') if options[:complete].present?
  end

  def language_filter
    parent_term_filter(:language_id, options[:language_id].to_i) if options[:language_id].present?
  end

  def pseud_filter
    terms_filter(:pseud_id, options[:pseud_ids]) if options[:pseud_ids].present?
  end

  def user_filter
    terms_filter(:user_id, options[:user_ids]) if options[:user_ids].present?
  end

  def filter_id_filter
   if filter_ids.present?
      filter_ids.map{ |filter_id| parent_term_filter(:filter_ids, filter_id) }
    end
  end

  def tags_filter
    if options[:tag_ids].present?
      options[:tag_ids].map{ |tag_id| term_filter(:tag_ids, tag_id) }
    end
  end

  def collections_filter
    terms_filter(:collection_ids, options[:collection_ids]) if options[:collection_ids].present?
  end

  ####################
  # HELPERS
  ####################

  def facet_tags?
    true
  end

  def facet_collections?
    false
  end  

  def include_private?
    User.current_user && user_ids.include?(User.current_user.id)
  end

  def include_restricted?
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

  def filter_ids
    return @filter_ids if @filter_ids.present?
    @filter_ids = options[:filter_ids] || []
    %w(fandom rating warning category character relationship freeform).each do |tag_type|
      if options["#{tag_type}_ids".to_sym].present?
        @filter_ids += options["#{tag_type}_ids".to_sym]
      end
    end
    @filter_ids += named_tags
    @filter_ids.uniq
  end

  # Get the ids for tags passed in by name
  def named_tags
    tag_ids = []
    %w(fandom character relationship freeform other_tag).each do |tag_type|
      tag_names_key = "#{tag_type}_names".to_sym
      if options[tag_names_key].present?
        names = options[tag_names_key].split(",")
        tags = Tag.where(name: names, canonical: true)
        unless tags.empty?
          tag_ids += tags.map{ |tag| tag.id }
        end
      end
    end
    tag_ids
  end

  def parent_term_filter(field, value, options={})
    {
      has_parent: {
        type: "bookmarkable",
        filter: {
          term: options.merge(field => value)
        }
      }
    }
  end

  def parent_terms_filter(field, value, options={})
    {
      has_parent: {
        type: "bookmarkable",
        filter: {
          terms: options.merge(field => value)
        }
      }
    }
  end

end
