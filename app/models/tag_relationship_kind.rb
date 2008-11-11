# LEGACY - will be removed after beta has been migrated and the migrations reset

class TagRelationshipKind < ActiveRecord::Base
  has_many :tag_relationships
   
  def self.synonym
    find_by_name('synonym') || TagRelationshipKind.create({ :name => 'synonym'.t, :verb_phrase => "is the same as".t, :reciprocal => true, :distance => 0 })
  end
  
  def self.child
    find_by_name('child') || TagRelationshipKind.create({ :name => 'child'.t, :verb_phrase => "belongs to".t, :distance => 1 })
  end
end
