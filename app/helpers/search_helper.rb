module SearchHelper

  # modified from mislav-will_paginate-2.3.2/lib/will_paginate/view_helpers.rb
  def search_header(collection, search_query, item_name)
    if search_query.blank?
      search_query = " found"
    else
      search_query = html_escape search_query
      search_query = " found for '#{search_query}'"
    end
    if collection.total_pages < 2
      case collection.size
        when 0
          "0 #{item_name.pluralize} #{search_query}"
        when 1
          "1 #{item_name} #{search_query}"
        else
          "#{collection.total_entries.to_s} #{item_name.pluralize} #{search_query}"
      end
    else
      %{ %d - %d of %d }% [
        collection.offset + 1,
        collection.offset + collection.length,
        collection.total_entries
      ] + item_name.pluralize + search_query
    end
  end
  
end