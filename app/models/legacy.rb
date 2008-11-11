# LEGACY - will be removed after xen has been migrated and the migrations reset

class Legacy < Tag
  belongs_to :tag_category
  has_many :tag_relationships
  has_many :related_relationships, :foreign_key => 'related_tag_id', :class_name => 'TagRelationship'  
  has_many :tags, :through => :related_relationships
  has_many :related_tags, :through => :tag_relationships
 
  NAME = "Legacy"

end

