class TagRelationship < ActiveRecord::Base
  has_many :taggings
   
  validates_numericality_of :distance, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 3

  # required synonym relationship, if it doesn't exist, create it.
  def self.synonyms
    find_by_name('synonyms') || TagRelationship.create({ :name => 'synonyms'.t, :verb_phrase => "is another name for".t, :reciprocal => true, :distance => 0 })
  end

  # required disambiguate relationship, if it doesn't exist, create it.
  def self.disambiguations
    find_by_name('disambiguations') || TagRelationship.create({ :name => 'disambiguations'.t, :verb_phrase => "might refer to".t, :reciprocal => true, :distance => 0 })
  end
  
  # force creation in an empty database
  self.synonyms
  self.disambiguations

end
