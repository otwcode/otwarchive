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

  def parsed_included_tags
    @parsed_included_tags ||= parse_named_tags(%i[tag])
  end

  # Combine the available filters
  def filters
    [
      multifandom_filter,
      signup_open_filter,
      closed_filter,
      challenge_type_filter,
      maintainer_filter,
      parent_filter,
      moderated_filter,
      signup_closes_in_future_filter,
      filter_id_filter,
      named_tag_inclusion_filter
    ].flatten.compact
  end

  def queries
    @queries = [
      general_query
    ].flatten.compact
  end

  ####################
  # FILTERS
  ####################

  def multifandom_filter
    term_filter(:multifandom, bool_value(options[:multifandom])) if options[:multifandom].present?
  end

  def signup_open_filter
    term_filter(:signup_open, bool_value(options[:signup_open])) if options[:signup_open].present?
  end

  def signup_closes_in_future_filter
    { range: { signups_close_at: { gt: "now" } } } if options[:signup_open].present?
  end

  def closed_filter
    term_filter(:closed, bool_value(options[:closed])) if options[:closed].present?
  end

  def moderated_filter
    term_filter(:moderated, bool_value(options[:moderated])) if options[:moderated].present?
  end

  def maintainer_filter
    term_filter(:maintainer_ids, options[:maintainer_id]) if options[:maintainer_id].present?
  end

  def challenge_type_filter
    return if options[:challenge_type].blank?

    type_param = options[:challenge_type]
    challenge_type = %w[PromptMeme GiftExchange].include?(type_param) ? type_param : "NULL"

    term_filter(:challenge_type, challenge_type)
  end

  def parent_filter
    term_filter(:parent_id, options[:parent_id]) if options[:parent_id].present?
  end

  def filter_id_filter
    return if filter_ids.blank?

    filter_ids.map { |filter_id| term_filter(:filter_ids, filter_id) }
  end

  def named_tag_inclusion_filter
    return if included_tag_names.blank?

    match_filter(:tag, included_tag_names.join(" "))
  end

  ####################
  # QUERIES
  ####################

  # Search for a collection by name
  def general_query
    input = options[:title] || ""
    query = escape_reserved_characters(input)

    return if query.blank?

    {
      query_string: {
        query: query,
        fields: ["title"],
        default_operator: "AND"
      }
    }
  end

  ####################
  # SORTING
  ####################

  def sort_column
    options[:sort_column].presence || "created_at"
  end

  def sort
    options[:sort_column] = sort_column.sub("public", "general") if (@user.present? || options[:admin_logged_in]) && sort_column.include?("public")
    direction = options[:sort_direction].presence
    direction ||= if sort_column.include?("title") || sort_column.include?("signups_close_at")
                    "asc"
                  else
                    "desc"
                  end
    [{ sort_column => { order: direction } }, { "id" => { order: direction } }]
  end
end
