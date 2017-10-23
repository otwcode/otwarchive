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
      bookmarkable_filters
    ).flatten.compact
  end

  def exclusion_filters
    @exclusion_filters ||= tag_exclusion_filter
  end

  def queries
    @queries = [general_query] unless general_query.blank?
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
    input = (options[:q] || options[:query])
    query = generate_search_text( input || '' )

    { query_string: { query: query } } unless query.blank?
  end

  def generate_search_text(query = '')
    search_text = query
    [:bookmarker].each do |field|
      if self.options[field].present?
        self.options[field].split(" ").each do |word|
          if word[0] == "-"
            search_text << " NOT "
            word.slice!(0)
          end
          word = escape_reserved_characters(word)
          search_text << " #{field.to_s}:#{word}"
        end
      end
    end
    escape_slashes(search_text.strip)
  end

  def sort
    column = options[:sort_column].present? ? options[:sort_column] : 'created_at'
    direction = options[:sort_direction].present? ? options[:sort_direction] : 'desc'
    sort_hash = { column => { order: direction } }

    if column == 'created_at'
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
    if options[:tag].present?
      tag = Tag.find_by name: options[:tag]
      options[:tag_ids] ||= []
      options[:tag_ids] << tag.id if tag
    end

    if options[:tag_ids].present?
      options[:tag_ids].map { |tag_id| term_filter(:tag_ids, tag_id) }
    end
  end

  def collections_filter
    terms_filter(:collection_ids, options[:collection_ids]) if options[:collection_ids].present?
  end

  def tag_exclusion_filter
    if exclusion_ids.present?
      exclusion_ids.flatten.map { |exclusion_id| parent_term_filter(:filter_ids, exclusion_id) }
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

  # TODO: this is an awful lot of queries
  # Also remove children from this unless the tag is a character
  def exclusion_ids
    return if options[:excluded_tag_names].blank? && options[:excluded_tag_ids].blank?
    names = options[:excluded_tag_names].split(",") if options[:excluded_tag_names]
    excluded_tags = []

    if names
      excluded_tags = (Tag.where(name: names, canonical: true) +
                        Tag.where(name: names, canonical: false).map(&:merger)).flatten.compact
    end

    if options[:excluded_tag_ids]
      excluded_tags += (Tag.where(id: options[:excluded_tag_ids], canonical: true) +
                          Tag.where(id: options[:excluded_tag_ids], canonical: false).map(&:merger)).flatten
    end

    excluded_tags.pluck(:id).compact +
      excluded_tags.map(&:sub_tags).flatten.pluck(:id).compact +
      excluded_tags.map(&:children).flatten.pluck(:id).compact
  end

end
