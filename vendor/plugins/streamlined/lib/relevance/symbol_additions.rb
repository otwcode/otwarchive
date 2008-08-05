module Relevance; end
module Relevance::SymbolAdditions
  def titleize
    to_s.titleize
  end
end

Symbol.class_eval {include Relevance::SymbolAdditions}
