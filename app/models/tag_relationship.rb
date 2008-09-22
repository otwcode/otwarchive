class TagRelationship < ActiveRecord::Base
  belongs_to :tag
  belongs_to :tag_relationship_kind
  belongs_to :related_tag, :class_name => 'Tag'
  validates_presence_of :tag, :tag_relationship_kind, :related_tag
  validates_uniqueness_of :tag_relationship_kind_id, :scope => [:tag_id, :related_tag_id]
  
  after_create :reassign_synonyms
  
  # Finds the existing relationships between tags in one category and tags in another
  def self.tagged_by_category(category1, category2)
    TagRelationship.find(:all, :include => [:tag, :related_tag], :conditions => ['tags.tag_category_id = ? AND related_tags_tag_relationships.tag_category_id = ?', category1.id, category2.id])
  end
  
  # If this is a synonym relationship and one of the tags is canonical, reassign the synonym's works to the canonical tag
  def reassign_synonyms
    if tag_relationship_kind == TagRelationshipKind.synonym && (related_tag.canonical? || tag.canonical?)
      canonical_tag = related_tag.canonical? ? related_tag : tag
      synonym = related_tag.canonical? ? tag : related_tag 
      for work in synonym.works
        work.tags << canonical_tag unless work.tags.include?(canonical_tag)
        work.tags = work.tags - [synonym]
      end
    end
  end
  
end
