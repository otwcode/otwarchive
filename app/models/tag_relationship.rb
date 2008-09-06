class TagRelationship < ActiveRecord::Base
  belongs_to :tag, :counter_cache => true
  belongs_to :tag_relationship_kind
  belongs_to :related_tag, :class_name => 'Tag'

end
