class TagRelationship < ActiveRecord::Base
  belongs_to :tag
  belongs_to :tag_relationship_kind
  belongs_to :related_tag, :class_name => 'Tag'
  validates_presence_of :tag, :tag_relationship_kind, :related_tag
end
