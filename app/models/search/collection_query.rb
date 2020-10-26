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
    [signup_open_filter, closed_filter, challenge_type_filter, fandom_filter, owner_filter, moderator_filter, parent_filter, moderated_filter].compact
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

  def closed_filter
    term_filter(:closed, bool_value(options[:closed])) if options[:closed].present?
  end

  def moderated_filter
    term_filter(:moderated, bool_value(options[:moderated])) if options[:moderated].present?
  end

  def fandom_filter
    return unless options[:fandom_ids].present?

    key = User.current_user.present? ? :general_fandom_ids : :public_fandom_ids
    options[:fandom_ids].flatten.uniq.map { |fandom_id| term_filter(key, fandom_id) } if options[:fandom_ids].present?
  end

  def owner_filter
    options[:owner_ids].flatten.uniq.map { |owner_id| term_filter(:owner_ids, owner_id) } if options[:owner_ids].present?
  end

  def moderator_filter
    options[:moderator_ids].flatten.uniq.map { |moderator_id| term_filter(:moderator_ids, moderator_id) } if options[:moderator_ids].present?
  end

  def challenge_type_filter
    if options[:challenge_type].present?
      type_param = options[:challenge_type]
      challenge_type = (type_param == 'PromptMeme' || type_param == 'GiftExchange') ? type_param : 'NULL'

      match_filter(:challenge_type, challenge_type)
    end
  end

  def parent_filter
    match_filter(:parent_id, options[:parent_id]) if options[:parent_id].present?
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
