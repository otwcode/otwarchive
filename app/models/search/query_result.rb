class QueryResult

  include Enumerable

  attr_reader :klass, :response, :current_page, :per_page

  def initialize(model_name, response, options={})
    @klass = model_name.classify.constantize
    @response = response
    @current_page = options[:page] || 1
    @per_page = options[:per_page] || 20
  end

  def hits
  	response['hits']['hits']
  end

  def items
    if @items.nil?
      @items = klass.load_from_elasticsearch(hits)
    end
    @items
  end

  # Laying some groundwork for making better use of search results
  def decorate_items(items)
    return items unless klass == Pseud
    PseudDecorator.decorate_from_search(items, hits)
  end

  def each(&block)
    items.each(&block)
  end

  def empty?
    items.empty?
  end

  def size
    items.size
  end
  alias :length :size

  def [](index)
    items[index]
  end

  def to_ary
    items
  end

  def load_tag_facets(type, info)
    @facets[type] = []
    buckets = info["buckets"]
    ids = buckets.map { |result| result['key'] }
    tags = Tag.where(id: ids).group_by(&:id)
    buckets.each do |facet|
      if tags[facet['key'].to_i].any?
        @facets[type] << QueryFacet.new(facet['key'], tags[facet['key'].to_i].first.name, facet['doc_count'])
      end
    end
  end

  def load_collection_facets(info)
    @facets["collections"] = []
    buckets = info["buckets"]
    ids = buckets.map { |result| result['key'] }
    collections = Collection.where(id: ids).group_by(&:id)
    buckets.each do |facet|
      unless collections[facet['key'].to_i].blank?
        @facets["collections"] << QueryFacet.new(facet['key'], collections[facet['key'].to_i].first.title, facet['doc_count'])
      end
    end
  end

  def facets
    return if response['aggregations'].nil?

    if @facets.nil?
      @facets = {}
      response['aggregations'].each_pair do |term, results|
        if Tag::TYPES.include?(term.classify) || term == 'tag'
          load_tag_facets(term, results)
        elsif term == 'collections'
          load_collection_facets(results)
        elsif term == 'bookmarks'
          load_tag_facets("tag", results["filtered_bookmarks"]["tag"])
        end
      end
    end
    @facets
  end

  def total_pages
    (total_entries / per_page.to_f).ceil rescue 0
  end

  def total_entries
    response['hits']['total']
  end

  def offset
    (current_page * per_page) - per_page
  end

end

class QueryFacet < Struct.new(:id, :name, :count)
end
