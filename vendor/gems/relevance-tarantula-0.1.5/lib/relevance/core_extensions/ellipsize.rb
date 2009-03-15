module Relevance::CoreExtensions::Nil
  def ellipsize(cutoff = 20)
    ""
  end
end

module Relevance::CoreExtensions::String
  def ellipsize(cutoff = 20)
    if length > cutoff
      "#{self[0...cutoff]}..."
    else
      self
    end
  end
end
 
module Relevance::CoreExtensions::Object
  def ellipsize(cutoff = 20)
    inspect.ellipsize(cutoff)
  end
end

class Object
  include Relevance::CoreExtensions::Object
end
class String
  include Relevance::CoreExtensions::String
end
class NilClass
  include Relevance::CoreExtensions::Nil
end
  
  

