class SearchResult
  
  include Enumerable

  attr_reader :klass, :tire_response

  def initialize(model_name, response)
    raise "Redshirt: Attempted to constantize invalid class initialize #{model_name.classify}" unless %w(Bookmark Pseud Tag Work).include?(model_name.classify)
    @klass = model_name.classify.constantize
    @tire_response = response
  end
    
  # Find results with where rather than find in order to avoid ActiveRecord::RecordNotFound
  def items
    if @items.nil?
      ids = tire_response.results.map { |item| item['id'] }
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
    return if tire_response.facets.nil?
    if @facets.nil?
      @facets = {}
      tire_response.facets.each_pair do |term, results|
        @facets[term] = []
        results = results['terms']
        if Tag::TYPES.include?(term.classify) || term == 'tag'
          ids = results.map{ |result| result['term'] }
          tags = Tag.where(id: ids).group_by(&:id)
          results.each do |facet|
            unless tags[facet['term'].to_i].blank?
              @facets[term] << SearchFacet.new(facet['term'], tags[facet['term'].to_i].first.name, facet['count'])
            end
          end
        elsif term == 'collections'
          ids = results.map{ |result| result['term'] }
          collections = Collection.where(id: ids).group_by(&:id)
          results.each do |facet|
            unless collections[facet['term'].to_i].blank?
              @facets[term] << SearchFacet.new(facet['term'], collections[facet['term'].to_i].first.title, facet['count'])
            end
          end
        end
      end
    end
    @facets
  end
  
  def total_pages
    tire_response.total_pages
  end
  
  def total_entries
    tire_response.total_entries
  end
  
  def per_page
    tire_response.per_page
  end
  
  def offset
    tire_response.offset
  end
  
  def current_page
    tire_response.current_page
  end
  
end

class SearchFacet < Struct.new(:id, :name, :count)
end
