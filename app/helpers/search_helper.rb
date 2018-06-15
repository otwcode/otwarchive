module SearchHelper

  # modified from mislav-will_paginate-2.3.2/lib/will_paginate/view_helpers.rb
  def search_header(collection, search, item_name, parent=nil)
    header = ""
    if !collection.respond_to?(:total_pages)
      header = ts "Recent #{item_name.pluralize}"
    elsif collection.total_pages < 2
      header = pluralize(collection.size, item_name)
    else
      total_entries = collection.total_entries
      total_entries = collection.unlimited_total_entries if collection.respond_to?(:unlimited_total_entries)
      header = %{ %d - %d of %d }% [
                collection.offset + 1,
                collection.offset + collection.length,
                total_entries
                ] + item_name.pluralize
    end
    if search.present? && search.query.present?
      header << " found"
    end
    if parent
      parent_text = case parent.class.to_s
                    when 'Collection'
                      " in #{link_to(parent.title, parent)}"
                    when 'Pseud'
                      " by #{parent.byline}"
                    when 'User'
                      " by #{parent.login}"
                    end
      if parent.is_a?(Tag)
        parent_text = " in #{link_to_tag_with_text(parent, parent.name)}"
      end
      if @fandom.present?
        parent_text << " in #{link_to_tag(@fandom)}"
      end
      header << parent_text
    end
    header.html_safe
  end


  def random_search_tip
    ArchiveConfig.SEARCH_TIPS[rand(ArchiveConfig.SEARCH_TIPS.size)]
  end

end
