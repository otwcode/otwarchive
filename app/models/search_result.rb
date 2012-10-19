class SearchResult
  
  include Enumerable

  attr_reader :klass, :tire_response

  def initialize(model_name, response)
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
    tire_response.facets
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
