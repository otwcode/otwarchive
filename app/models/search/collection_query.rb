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
      challenge_type_filter
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

  def challenge_type_filter
    term_filter(:challenge_type, options[:challenge_type]) if options[:challenge_type].present?
  end


  # TODO: wire this up for collections
  def fandom_filter
    key = User.current_user.present? ? "fandoms.id" : "fandoms.id_for_public"
    if options[:fandom_ids]
      options[:fandom_ids].map do |fandom_id|
        { term: { key => fandom_id } }
      end
    end
  end

  # filtering
  # 
  # owner_ids
  # moderator_ids
  # general_fandom_ids
  # public_fandom_ids
  # ([] & []).any?

  # decorator
  # 
  # general_fandoms_count
  # general_works_count
  # general_bookmarked_items_count
  # public_fandoms_count
  # public_works_count
  # public_bookmarked_items_count


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
