class TagSetAssociation < ActiveRecord::Base
  belongs_to :owned_tag_set
  belongs_to :tag
  belongs_to :parent_tag, :class_name => "Tag"

  validates_uniqueness_of :tag_id, :scope => [:owned_tag_set_id, :parent_tag_id], :message => ts("^You have already associated those tags in your set.")
  
  attr_accessor :create_association
  
  def self.for_tag_set(tagset)
    where(:owned_tag_set_id => tagset.id)
  end

  def parent_tagname
    @parent_tagname || self.parent_tag.name
  end
  
  def parent_tagname=(parent_tagname)
    self.parent_tag = Tag.find_by_name(parent_tagname)
  end

  validates_presence_of :tag_id, :parent_tag_id, :owned_tag_set_id

end
