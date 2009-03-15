# Used to create a stub response when we didn't get back a real response
class Relevance::Tarantula::Response
  HASHABLE_ATTRS = [:code, :body, :content_type]
  attr_accessor *HASHABLE_ATTRS

  def initialize(hash)
    hash.each do |k,v|
      raise ArgumentError, k unless HASHABLE_ATTRS.member?(k)
      self.instance_variable_set("@#{k}", v)
    end
  end
  
end