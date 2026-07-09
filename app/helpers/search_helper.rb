module SearchHelper
  SEARCH_HEADER_ITEM_TYPES = %i[
    bookmark
    bookmarked_item
    challenge_signup
    collection
    comment
    series
    tag_set
    unposted_draft
    user
    work
  ].freeze

  SearchHeaderResult = Struct.new(:item_type, :kind, :translation_count, :variables, keyword_init: true)
  SearchHeaderLocation = Struct.new(:key, :variables, keyword_init: true)

  # modified from mislav-will_paginate-2.3.2/lib/will_paginate/view_helpers.rb
  def search_header(collection, item_type:, search: nil, parent: nil, fandom: nil, query_present: nil)
    result = search_header_result(collection, item_type)
    location = search_header_location(parent, fandom)
    has_query = search_query_present?(search, query_present)

    if has_query && location.present?
      search_header_text(result, "with_query_and_#{location.key}", location)
    elsif has_query
      search_header_text(result, "with_query")
    elsif location.present?
      search_header_text(result, "with_#{location.key}", location)
    else
      search_header_text(result)
    end
  end

  def search_results_found(results)
    t("search_helper.search_results_found",
      count: number_with_delimiter(results.unlimited_total_entries))
  end

  def random_search_tip
    ArchiveConfig.SEARCH_TIPS[rand(ArchiveConfig.SEARCH_TIPS.size)]
  end

  def works_original_path
    url_for(
      controller: :works,
      action: :index,
      only_path: true,
      **params.slice(:tag_id, :fandom_id, :collection_id, :pseud_id, :user_id).permit!
    )
  end

  def bookmarks_original_path
    url_for(
      controller: :bookmarks,
      action: :index,
      only_path: true,
      **params.slice(:tag_id, :collection_id, :pseud_id, :user_id).permit!
    )
  end

  private

  def search_header_result(collection, item_type)
    raise ArgumentError, "Unknown search header item type: #{item_type.inspect}" unless SEARCH_HEADER_ITEM_TYPES.include?(item_type)

    if !collection.respond_to?(:total_pages)
      SearchHeaderResult.new(item_type: item_type, kind: "recent", translation_count: collection.size, variables: {})
    elsif collection.total_pages < 2
      SearchHeaderResult.new(item_type: item_type, kind: "count", translation_count: collection.total_entries, variables: {})
    else
      total_entries = collection.respond_to?(:unlimited_total_entries) ? collection.unlimited_total_entries : collection.total_entries

      SearchHeaderResult.new(
        item_type: item_type,
        kind: "range",
        translation_count: total_entries,
        variables: {
          start_number: number_with_delimiter(collection.offset + 1),
          end_number: number_with_delimiter(collection.offset + collection.length),
          total: number_with_delimiter(total_entries)
        }
      )
    end
  end

  def search_header_text(result, suffix = nil, location = nil)
    translation_key = [result.kind, suffix].compact.join("_")
    variables = result.variables.merge(count: result.translation_count)
    variables.merge!(location.variables) if location.present?

    t("search_helper.search_header.items.#{result.item_type}.#{translation_key}", **variables)
  end

  def search_header_location(parent, fandom)
    locations = []

    case parent
    when Collection
      locations << SearchHeaderLocation.new(
        key: "collection_html",
        variables: { collection_link: link_to(parent.title, parent) }
      )
    when Pseud
      locations << SearchHeaderLocation.new(
        key: "pseud",
        variables: { byline: parent.byline }
      )
    when User
      locations << SearchHeaderLocation.new(
        key: "user",
        variables: { username: parent.login }
      )
    when Language
      locations << SearchHeaderLocation.new(
        key: "language",
        variables: { language: parent.name }
      )
    end

    if parent.is_a?(Tag)
      locations << SearchHeaderLocation.new(
        key: "tag_html",
        variables: { tag_link: link_to_tag_with_text(parent, parent.name) }
      )
    end

    # The @fandom version is used when following a fandom link from a user's dashboard,
    # which will take you to a URL like /users/username/works?fandom_id=123.
    if fandom.present?
      locations << SearchHeaderLocation.new(
        key: "fandom_html",
        variables: { fandom_link: link_to_tag(fandom) }
      )
    end

    return locations.first unless locations.size > 1

    first_location, second_location = locations
    SearchHeaderLocation.new(
      key: "#{first_location.key.sub(/_html\z/, '')}_and_#{second_location.key}",
      variables: first_location.variables.merge(second_location.variables)
    )
  end

  def search_query_present?(search, query_present)
    return query_present unless query_present.nil?

    search.present? && search.respond_to?(:query) && search.query.present?
  end
end
