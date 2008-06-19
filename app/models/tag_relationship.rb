class TagRelationship < ActiveRecord::Base
   has_many :taggings
   
   validates_numericality_of :distance, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 3

end
