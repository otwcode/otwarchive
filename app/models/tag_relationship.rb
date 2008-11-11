# LEGACY - will be removed after beta has been migrated and the migrations reset

class TagRelationship < ActiveRecord::Base
  belongs_to :tag
  belongs_to :tag_relationship_kind
  belongs_to :related_tag, :class_name => 'Tag'
  
  def self.synonyms
    self.find_all_by_tag_relationship_kind_id(TagRelationshipKind.synonym.id)
  end
end
