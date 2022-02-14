class TagQuery < Query

  def klass
    'Tag'
  end

  def index_name
    TagIndexer.index_name
  end

  def document_type
    TagIndexer.document_type
  end

  def filters
    [
      type_filter,
      canonical_filter,
      unwrangleable_filter,
      posted_works_filter,
      media_filter,
      fandom_filter,
      character_filter,
      suggested_fandom_filter,
      suggested_character_filter,
      named_fandom_inclusion_filter
    ].flatten.compact
  end

  def exclusion_filters
    [
      wrangled_filter
    ].compact
  end

  def queries
    [name_query].compact
  end

  # Tags have a different default per_page value:
  def per_page
    options[:per_page] || ArchiveConfig.TAGS_PER_SEARCH_PAGE || 50
  end

  def sort
    direction = options[:sort_direction]&.downcase
    case options[:sort_column]
    when "taggings_count_cache", "uses"
      column = "uses"
      direction ||= "desc"
    when "created_at"
      column = "created_at"
      direction ||= "desc"
    else
      column = "name.keyword"
      direction ||= "asc"
    end
    sort_hash = { column => { order: direction } }

    if column == "created_at"
      sort_hash[column][:unmapped_type] = "date"
    end

    sort_hash
  end

  ################
  # FILTERS
  ################

  def type_filter
    { term: { tag_type: options[:type] } } if options[:type]
  end

  def canonical_filter
    term_filter(:canonical, bool_value(options[:canonical])) if options[:canonical].present?
  end

  def unwrangleable_filter
    term_filter(:unwrangleable, bool_value(options[:unwrangleable])) unless options[:unwrangleable].nil?
  end

  def posted_works_filter
    term_filter(:has_posted_works, bool_value(options[:has_posted_works])) unless options[:has_posted_works].nil?
  end

  def media_filter
    terms_filter(:media_ids, options[:media_ids]) if options[:media_ids]
  end

  def fandom_filter
    # Parse given fandom names and returns a list of ids found in the database.
    options[:fandom_ids] ||= parse_named_tags(options[:fandom_names])[:ids] if options[:fandom_names]
    
    options[:fandom_ids]&.map { |fandom_id| term_filter(:fandom_ids, fandom_id) }
  end

  def character_filter
    terms_filter(:character_ids, options[:character_ids]) if options[:character_ids]
  end

  def suggested_fandom_filter
    terms_filter(:pre_fandom_ids, options[:pre_fandom_ids]) if options[:pre_fandom_ids]
  end

  def suggested_character_filter
    terms_filter(:pre_character_ids, options[:pre_character_ids]) if options[:pre_character_ids]
  end

  # Filter to only include tags that have no assigned fandom_ids. Checks that
  # the fandom exists, because this particular filter is included in the
  # exclusion_filters section.
  def wrangled_filter
    { exists: { field: "fandom_ids" } } unless options[:wrangled].nil?
  end

  # This filter is used to restrict results to only include tags whose fandoms
  # matches all of the fandom names provided. This is useful when the user
  # enters a non-existent fandom, which would be discarded by fandom_filter.
  def named_fandom_inclusion_filter
    included_fandom_names ||= parse_named_tags(options[:fandom_names])[:missing] if options[:fandom_names]

    return if included_fandom_names.blank?

    match_filter(:name, included_fandom_names.join(" "))
  end

  ####################
  # HELPERS
  ####################

  # Used by fandom_filter and named_fandom_inclusion_filter.
  # Uses the database to look up all of the tag names listed in the passed-in
  # field. Returns a hash with the following format:
  #   {
  #     ids: [1, 2, 3],
  #     missing: ["missing tag name", "other missing"]
  #   }
  def parse_named_tags(field)
    names = all_tag_names(field)
    found = names ? Tag.where(name: names).pluck(:id, :name) : []

    {
      ids: found.map(&:first),
      missing: (names - found.map(&:second)).uniq
    }
  end

  # Used by parse_named_tags.
  # Parse the options for a passed-in field, treating it as a comma-separated
  # list of tags. Returns the list of tags, blank and duplicate tags removed.
  def all_tag_names(field)
    field.split(",").map(&:squish).reject(&:blank?).uniq
  end

  ################
  # QUERIES
  ################

  def name_query
    return unless options[:name]
    {
      query_string: {
        query: escape_reserved_characters(options[:name]),
        fields: ["name.exact^2", "name"],
        default_operator: "and"
      }
    }
  end
end
