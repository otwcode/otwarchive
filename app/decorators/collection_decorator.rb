class CollectionDecorator < SimpleDelegator

  attr_reader :data

  # Collections need to be decorated with various stats from the "_source" when
  # viewing search results, so we first load the collections with the base search
  # class, and then decorate them with the data.
  def self.load_from_elasticsearch(hits)
    items = Collection.load_from_elasticsearch(hits)
    decorate_from_search(items, hits)
  end

   # TODO: Either eliminate this function or add definitions for work_counts and
  # bookmark_counts (and possibly fandom information, as well?). The NameError
  # that this causes isn't a problem at the moment because the function isn't
  # being called from anywhere, but it needs to be fixed before it can be used.
  def self.decorate_from_search(results, search_hits)
    search_data = search_hits.group_by { |doc| doc["_id"] }
    results.map do |result|
      data = search_data[result.id.to_s].first&.dig('_source') || {}
      new_with_data(result, data)
    end
  end

  def self.new_with_data(collection, data)
    new(collection).tap do |decorator|
      decorator.data = data
    end
  end

  def data=(info)
    @data = HashWithIndifferentAccess.new(info)
  end

  def works_count
    count = User.current_user.present? ? data[:general_works_count] : data[:public_works_count]
    count || 0
  end

  def bookmarks_count
    User.current_user.present? ? data[:general_bookmarked_items_count] : data[:public_bookmarked_items_count]
  end

  def fandoms_count
    User.current_user.present? ? data[:general_fandoms_count] : data[:public_fandoms_count]
  end
end
