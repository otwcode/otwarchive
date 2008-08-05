module Relevance; end
module Relevance::MethodAdditions
  def name
    # convert '#<Method: String#to_s>' to 'to_s'
    self.inspect.match(/.*?([a-z_]*)>$/)[1]
  end
end
Method.class_eval {include Relevance::MethodAdditions}
