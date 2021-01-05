class CollectionQuery < Query
  include TaggableQuery

  # The "klass" function in the query classes is used only to determine what
  # type of search results to return (that is, which class the QueryResult
  # class will call "load_from_elasticsearch" on). Because the Collection search
  # should always wrap Collections up in a CollectionDecorator, we return CollectionDecorator
  # instead of Collection.
  def klass
    "CollectionDecorator"
  end

  def index_name
    CollectionIndexer.index_name
  end

  def document_type
    CollectionIndexer.document_type
  end 

  # Combine the available filters
  def filters
    [signup_open_filter, closed_filter, challenge_type_filter, owner_filter, maintainer_filter, moderator_filter, parent_filter, moderated_filter, signup_closes_in_future_filter].compact
  end

  # Combine the available queries
  # In this case, name is the only text field
  def queries
    @queries = [
      general_query
    ].flatten.compact
  end

  ####################
  # FILTERS
  ####################

  def signup_open_filter
    term_filter(:signup_open, bool_value(options[:signup_open])) if options[:signup_open].present?
  end

  def signup_closes_in_future_filter
    { range: { signups_close_at: { gte: "now" } } } if options[:signup_open].present?
  end

  def closed_filter
    term_filter(:closed, bool_value(options[:closed])) if options[:closed].present?
  end

  def moderated_filter
    term_filter(:moderated, bool_value(options[:moderated])) if options[:moderated].present?
  end

  def owner_filter
    options[:owner_ids].flatten.uniq.map { |owner_id| term_filter(:owner_ids, owner_id) } if options[:owner_ids].present?
  end

  def moderator_filter
    options[:moderator_ids].flatten.uniq.map { |moderator_id| term_filter(:moderator_ids, moderator_id) } if options[:moderator_ids].present?
  end

  def maintainer_filter
    term_filter(:maintainer_ids, options[:maintainer_id]) if options[:maintainer_id].present?
  end

  def challenge_type_filter
    if options[:challenge_type].present?
      type_param = options[:challenge_type]
      challenge_type = (type_param == "PromptMeme" || type_param == "GiftExchange") ? type_param : "NULL"

      match_filter(:challenge_type, challenge_type)
    end
  end

  def parent_filter
    match_filter(:parent_id, options[:parent_id]) if options[:parent_id].present?
  end

  def filter_id_filter
    return unless filter_ids.present?

    filter_ids.map { |filter_id| term_filter(:filter_ids, filter_id) }
  end

  # This filter is used to restrict our results to only include collections
  # whose "tag" text matches all of the tag names in tag. This is useful when the user
  # enters a non-existent tag, which would be discarded by the TaggableQuery.filter_ids function.
  def tag_filter
    match_filter(:tag, options[:tag].join(" ")) if options[:tag].present?
  end

  ####################
  # QUERIES
  ####################

  # Search for a collection by name
  def general_query
    input = (options[:query] || options[:title] || "").dup
    query = escape_reserved_characters(input)

    return {
      query_string: {
        query: query,
        fields: ["title^5", "name"],
        default_operator: "AND"
      }
    } if query.present?
  end

  ####################
  # SORTING
  ####################

  def sort_column
    options[:sort_column].present? ? options[:sort_column] : "created_at"
  end

  def sort
    direction = options[:sort_direction].present? ? options[:sort_direction] : "desc"
    { sort_column => { order: direction } }
  end
end
