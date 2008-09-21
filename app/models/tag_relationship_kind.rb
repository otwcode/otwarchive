class TagRelationshipKind < ActiveRecord::Base
  has_many :tag_relationships
   
  validates_numericality_of :distance, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 3

  # required disambiguate relationship, if it doesn't exist, create it.
  def self.disambiguation
    find_by_name('disambiguation') || TagRelationshipKind.create({ :name => 'disambiguation'.t, :verb_phrase => "might refer to".t, :reciprocal => true, :distance => 0 })
  end
  
  # required synonym relationship, if it doesn't exist, create it.
  def self.synonym
    find_by_name('synonym') || TagRelationshipKind.create({ :name => 'synonym'.t, :verb_phrase => "is the same as".t, :reciprocal => true, :distance => 0 })
  end
  
  # force creation in an empty database
  self.disambiguation
  self.synonym
end
