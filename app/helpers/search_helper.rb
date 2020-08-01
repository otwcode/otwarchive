module SearchHelper

  # modified from mislav-will_paginate-2.3.2/lib/will_paginate/view_helpers.rb
  def search_header(collection, search, item_name, parent=nil)
    header = []
    if !collection.respond_to?(:total_pages)
      header << ts("Recent #{item_name.pluralize}")
    elsif collection.total_pages < 2
      header << pluralize(collection.size, item_name)
    else
      total_entries = collection.total_entries
      total_entries = collection.unlimited_total_entries if collection.respond_to?(:unlimited_total_entries)
      header << %{ %d - %d of %d }% [
                collection.offset + 1,
                collection.offset + collection.length,
                total_entries
                ] + item_name.pluralize
    end
    if search.present? && search.query.present?
      header << "found"
    end

    case parent
    when Collection
      header << ts("in %{collection_link}", collection_link: link_to(parent.title, parent))
    when Pseud
      header << ts("by %{byline}", byline: parent.byline)
    when User
      header << ts("by %{username}", username: parent.login)
    end

    header << ts("in %{tag_link}", tag_link: link_to_tag_with_text(parent, parent.name)) if parent.is_a?(Tag)
    header << ts("in %{fandom_link}", fandom_link: link_to_tag(@fandom)) if @fandom.present?
    header.join(" ").html_safe
  end

  def search_results_found(results)
    ts("%{count} Found", count: results.unlimited_total_entries)
  end

  def random_search_tip
    ArchiveConfig.SEARCH_TIPS[rand(ArchiveConfig.SEARCH_TIPS.size)]
  end

end
