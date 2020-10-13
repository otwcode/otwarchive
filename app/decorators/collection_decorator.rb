class CollectionDecorator < SimpleDelegator

  attr_reader :data

  # Pseuds need to be decorated with various stats from the "_source" when
  # viewing search results, so we first load the pseuds with the base search
  # class, and then decorate them with the data.
  def self.load_from_elasticsearch(hits)
    items = Collection.load_from_elasticsearch(hits)
    decorate_from_search(items, hits)
  end

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
