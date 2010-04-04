class PotentialPromptMatch < ActiveRecord::Base
  # We use "-1" to represent all the requested items matching 
  ALL = -1

  belongs_to :potential_match
  belongs_to :offer
  belongs_to :request
  
  # sorting routine for potential matches
  include Comparable
  def <=>(other)
    return 0 if self.id == other.id 

    # we prioritize matches on fandom and move down the line 
    TagSet::TAG_TYPES.each do |type|
      cmp = compare_all(self.send("num_#{type.pluralize}_matched"), other.send("num_#{type.pluralize}_matched"))
      return cmp unless cmp == 0
    end

    # if we're a perfect match down to here just match on id
    return self.id <=> other.id
  end
  
protected
  def compare_all(self_value, other_value)
    self_value == ALL ? (other_value == ALL ? 0 : 1) : (other_value == ALL ? -1 : self_value <=> other_value)
  end
  
end
