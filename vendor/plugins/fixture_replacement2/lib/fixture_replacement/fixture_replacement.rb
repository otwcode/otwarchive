module FixtureReplacement  
  class InclusionError < StandardError; end
  
  class << self
    include FixtureReplacement::ClassMethods
  end
end


