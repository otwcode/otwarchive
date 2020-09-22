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
      closed_filter,
      moderated_filter,
      unrevealed_filter,
      anonymous_filter
    ]
  end

  def collection_filters
    [
      collection_type_filter
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

  def moderated_filter
    term_filter(:moderated, bool_value(options[:moderated])) if options[:moderated].present?
  end

  def unrevealed_filter
    term_filter(:unrevealed, bool_value(options[:unrevealed])) if options[:unrevealed].present?
  end

  def anonymous_filter
    term_filter(:anonymous, bool_value(options[:anonymous])) if options[:anonymous].present?
  end
  
  def collection_type_filter
    term_filter(:"collection_type", options[:collection_type]) if options[:collection_type].present?
  end

  ####################
  # QUERIES
  ####################

  # Search for a tag by name
  # Note that fields don't need to be explicitly included in the
  # field list to be searchable directly (ie, "complete:true" will still work)
  def general_query
    input = (options[:title] || "").dup
    query = escape_reserved_characters(input)

    return {
      query_string: {
        query: query,
        fields: ["name, title"],
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
    direction = options[:sort_direction].present? ? options[:sort_direction] : "desc"

    { sort_column => { order: direction } }
  end
end
