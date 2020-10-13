class CollectionQuery < Query
  def klass
    'Collection'
  end

  def index_name
    CollectionIndexer.index_name
  end

  def document_type
    CollectionIndexer.document_type
  end 

  # Combine the available filters
  def filters
    @filters ||= (
      visibility_filters +
      collection_filters
    ).flatten.compact
  end

  # Combine the available queries
  # In this case, name is the only text field
  def queries
    @queries = [
      general_query
    ].flatten.compact
  end

  ####################
  # GROUPS OF FILTERS
  ####################

  def visibility_filters
    [
      signup_open_filter,
      closed_filter
    ]
  end

  def collection_filters
    [
      challenge_type_filter,
      fandom_filter,
      owner_filter,
      moderator_filter
    ]
  end

  ####################
  # FILTERS
  ####################

  def signup_open_filter
    term_filter(:signup_open, bool_value(options[:signup_open])) if options[:signup_open].present?
  end

  def closed_filter
    term_filter(:closed, bool_value(options[:closed])) if options[:closed].present?
  end

  def fandom_filter
    key = User.current_user.present? ? :general_fandom_ids : :public_fandom_ids
    terms_filter(key, options[:fandom_ids]) if options[:fandom_ids].present?
  end

  def owner_filter
    terms_filter(:owner_ids, options[:owner_ids]) if options[:owner_ids].present?
  end

  def moderator_filter
    terms_filter(:moderator_ids, options[:moderator_ids]) if options[:moderator_ids].present?
  end

  def challenge_type_filter
    match_filter(:challenge_type, options[:challenge_type]) if options[:challenge_type].present?
  end

  ####################
  # QUERIES
  ####################

  # Search for a tag by name
  # Note that fields don't need to be explicitly included in the
  # field list to be searchable directly (ie, "complete:true" will still work)
  def general_query
    input = (options[:query] || options[:title] || "").dup
    query = escape_reserved_characters(input)

    return {
      query_string: {
        query: query,
        fields: ["title^5", "name"],
        default_operator: "AND"
      }
    } unless query.blank?
  end

  ####################
  # SORTING
  ####################

  def sort_column
    options[:sort_column].present? ? options[:sort_column] : 'created_at'
  end

  def sort
    direction = options[:sort_direction].present? ? options[:sort_direction] : 'desc'
    { sort_column => { order: direction } }
  end
end
