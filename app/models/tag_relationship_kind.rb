# LEGACY - will be removed after beta has been migrated and the migrations reset

class TagRelationshipKind < ActiveRecord::Base
  has_many :tag_relationships
   
  def self.synonym
    find_by_name('synonym') || TagRelationshipKind.create({ :name => 'synonym', :verb_phrase => "is the same as", :reciprocal => true, :distance => 0 })
  end
  
  def self.child
    find_by_name('child') || TagRelationshipKind.create({ :name => 'child', :verb_phrase => "belongs to", :distance => 1 })
  end
end
