module SearchHelper
  # modified from mislav-will_paginate-2.3.2/lib/will_paginate/view_helpers.rb
  def search_header(collection, item_type:, search: nil, parent: nil, fandom: nil, query_present: nil)
    results = search_header_results(collection, item_type)
    location = search_header_scope(parent, fandom)
    has_query = search_query_present?(search, query_present)

    if has_query && location.present?
      t("search_helper.search_header.with_query_and_scope_html",
        results: results,
        location: location)
    elsif has_query
      t("search_helper.search_header.with_query_html",
        results: results)
    elsif location.present?
      t("search_helper.search_header.with_scope_html",
        results: results,
        location: location)
    else
      t("search_helper.search_header.default_html",
        results: results)
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

  def search_header_results(collection, item_type)
    if !collection.respond_to?(:total_pages)
      search_header_recent(item_type, count: collection.size)
    elsif collection.total_pages < 2
      search_header_count(item_type, count: collection.total_entries)
    else
      total_entries = collection.respond_to?(:unlimited_total_entries) ? collection.unlimited_total_entries : collection.total_entries

      search_header_range(
        item_type,
        count: total_entries,
        start_number: number_with_delimiter(collection.offset + 1),
        end_number: number_with_delimiter(collection.offset + collection.length),
        total: number_with_delimiter(total_entries)
      )
    end
  end

  def search_header_recent(item_type, count:)
    case item_type
    when :bookmark
      t("search_helper.search_header.items.bookmark.recent", count: count)
    when :bookmarked_item
      t("search_helper.search_header.items.bookmarked_item.recent", count: count)
    when :challenge_signup
      t("search_helper.search_header.items.challenge_signup.recent", count: count)
    when :collection
      t("search_helper.search_header.items.collection.recent", count: count)
    when :comment
      t("search_helper.search_header.items.comment.recent", count: count)
    when :series
      t("search_helper.search_header.items.series.recent", count: count)
    when :tag_set
      t("search_helper.search_header.items.tag_set.recent", count: count)
    when :unposted_draft
      t("search_helper.search_header.items.unposted_draft.recent", count: count)
    when :user
      t("search_helper.search_header.items.user.recent", count: count)
    when :work
      t("search_helper.search_header.items.work.recent", count: count)
    else
      raise ArgumentError, "Unknown search header item type: #{item_type.inspect}"
    end
  end

  def search_header_count(item_type, count:)
    case item_type
    when :bookmark
      t("search_helper.search_header.items.bookmark.count", count: count)
    when :bookmarked_item
      t("search_helper.search_header.items.bookmarked_item.count", count: count)
    when :challenge_signup
      t("search_helper.search_header.items.challenge_signup.count", count: count)
    when :collection
      t("search_helper.search_header.items.collection.count", count: count)
    when :comment
      t("search_helper.search_header.items.comment.count", count: count)
    when :series
      t("search_helper.search_header.items.series.count", count: count)
    when :tag_set
      t("search_helper.search_header.items.tag_set.count", count: count)
    when :unposted_draft
      t("search_helper.search_header.items.unposted_draft.count", count: count)
    when :user
      t("search_helper.search_header.items.user.count", count: count)
    when :work
      t("search_helper.search_header.items.work.count", count: count)
    else
      raise ArgumentError, "Unknown search header item type: #{item_type.inspect}"
    end
  end

  def search_header_range(item_type, count:, start_number:, end_number:, total:)
    case item_type
    when :bookmark
      t("search_helper.search_header.items.bookmark.range",
        count: count, start_number: start_number, end_number: end_number, total: total)
    when :bookmarked_item
      t("search_helper.search_header.items.bookmarked_item.range",
        count: count, start_number: start_number, end_number: end_number, total: total)
    when :challenge_signup
      t("search_helper.search_header.items.challenge_signup.range",
        count: count, start_number: start_number, end_number: end_number, total: total)
    when :collection
      t("search_helper.search_header.items.collection.range",
        count: count, start_number: start_number, end_number: end_number, total: total)
    when :comment
      t("search_helper.search_header.items.comment.range",
        count: count, start_number: start_number, end_number: end_number, total: total)
    when :series
      t("search_helper.search_header.items.series.range",
        count: count, start_number: start_number, end_number: end_number, total: total)
    when :tag_set
      t("search_helper.search_header.items.tag_set.range",
        count: count, start_number: start_number, end_number: end_number, total: total)
    when :unposted_draft
      t("search_helper.search_header.items.unposted_draft.range",
        count: count, start_number: start_number, end_number: end_number, total: total)
    when :user
      t("search_helper.search_header.items.user.range",
        count: count, start_number: start_number, end_number: end_number, total: total)
    when :work
      t("search_helper.search_header.items.work.range",
        count: count, start_number: start_number, end_number: end_number, total: total)
    else
      raise ArgumentError, "Unknown search header item type: #{item_type.inspect}"
    end
  end

  def search_header_scope(parent, fandom)
    scopes = []

    case parent
    when Collection
      scopes << t("search_helper.search_header.scope.collection_html", collection_link: link_to(parent.title, parent))
    when Pseud
      scopes << t("search_helper.search_header.scope.pseud", byline: parent.byline)
    when User
      scopes << t("search_helper.search_header.scope.user", username: parent.login)
    when Language
      scopes << t("search_helper.search_header.scope.language", language: parent.name)
    end

    scopes << t("search_helper.search_header.scope.tag_html", tag_link: link_to_tag_with_text(parent, parent.name)) if parent.is_a?(Tag)
    # The @fandom version is used when following a fandom link from a user's dashboard,
    # which will take you to a URL like /users/username/works?fandom_id=123.
    scopes << t("search_helper.search_header.scope.fandom_html", fandom_link: link_to_tag(fandom)) if fandom.present?

    scopes.compact.reduce do |combined_scope, scope|
      t("search_helper.search_header.scope.combined_html",
        first_scope: combined_scope,
        second_scope: scope)
    end
  end

  def search_query_present?(search, query_present)
    return query_present unless query_present.nil?

    search.present? && search.respond_to?(:query) && search.query.present?
  end
end
