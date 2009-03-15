class Relevance::Tarantula::Attack
  HASHABLE_ATTRS = [:name, :input, :output, :description]
  attr_accessor *HASHABLE_ATTRS
  def initialize(hash)
    hash.each do |k,v|
      raise ArgumentError, k unless HASHABLE_ATTRS.member?(k)
      self.instance_variable_set("@#{k}", v)
    end
  end
  def ==(other)
    Relevance::Tarantula::Attack === other && HASHABLE_ATTRS.all? { |attr| send(attr) == other.send(attr)}
  end
end


