module SearchHelper

  # modified from mislav-will_paginate-2.3.2/lib/will_paginate/view_helpers.rb
  def search_header(collection, search, item_name, parent=nil)
    header = []
    if !collection.respond_to?(:total_pages)
      header << ts("Recent #{item_name.pluralize}")
    elsif collection.total_pages < 2
      header << pluralize(collection.total_entries, item_name)
    else
      total_entries = collection.total_entries
      total_entries = collection.unlimited_total_entries if collection.respond_to?(:unlimited_total_entries)
      header << ts(" %{start_number} - %{end_number} of %{total} %{things}",
                   start_number: collection.offset + 1,
                   end_number: collection.offset + collection.length,
                   total: total_entries,
                   things: item_name.pluralize)
    end
    header << ts("found") if search.present? && search.query.present?

    case parent
    when Collection
      header << ts("in %{collection_link}", collection_link: link_to(parent.title, parent))
    when Pseud
      header << ts("by %{byline}", byline: parent.byline)
    when User
      header << ts("by %{username}", username: parent.login)
    end

    header << ts("in %{tag_link}", tag_link: link_to_tag_with_text(parent, parent.name)) if parent.is_a?(Tag)
    # The @fandom version is used when following a fandom link from a user's dashboard, which
    # which will take you to a URL like /users/username/works?fandom_id=123.
    header << ts("in %{fandom_link}", fandom_link: link_to_tag(@fandom)) if @fandom.present?
    header.join(" ").html_safe
  end

  def search_results_found(results)
    ts("%{count} Found", count: results.unlimited_total_entries)
  end

  def random_search_tip
    ArchiveConfig.SEARCH_TIPS[rand(ArchiveConfig.SEARCH_TIPS.size)]
  end

  def original_path(var)
    case var
    when Tag, Fandom
      return tag_works_path(var) if params[:work_search].present?
      return tag_bookmarks_path(var) if params[:bookmark_search].present?
    when Pseud
      return user_pseud_works_path(var.user, var) if params[:work_search].present?
      return user_pseud_bookmarks_path(var.user, var) if params[:bookmark_search].present?
    when User
      return user_works_path(var) if params[:work_search].present?
      return user_bookmarks_path(var) if params[:bookmark_search].present?
    else
      "/"
    end
  end
end
