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
    
  # Find results with where rather than find in order to avoid ActiveRecord::RecordNotFound
  def items
    if @items.nil?
      ids = hits.map { |item| item['_id'] }
      items = klass.where(:id => ids).group_by(&:id)
      @items = ids.map{ |id| items[id.to_i] }.flatten.compact
    end
    @items
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
    self
  end
  
  def facets
    return if response['aggregations'].nil?
    if @facets.nil?
      @facets = {}
      response['aggregations'].each_pair do |term, results|
        @facets[term] = []
        results = results['buckets']
        if Tag::TYPES.include?(term.classify) || term == 'tag'
          ids = results.map{ |result| result['key'] }
          tags = Tag.where(id: ids).group_by(&:id)
          results.each do |facet|
            unless tags[facet['key'].to_i].blank?
              @facets[term] << QueryFacet.new(facet['key'], tags[facet['key'].to_i].first.name, facet['doc_count'])
            end
          end
        elsif term == 'collections'
          ids = results.map{ |result| result['key'] }
          collections = Collection.where(id: ids).group_by(&:id)
          results.each do |facet|
            unless collections[facet['key'].to_i].blank?
              @facets[term] << QueryFacet.new(facet['key'], collections[facet['key'].to_i].first.title, facet['doc_count'])
            end
          end
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