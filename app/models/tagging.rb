class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :tag_relationship
  belongs_to :taggable, :polymorphic => true

  def valid_tag
    return tag unless tag.banned
  end
  
  def self.tagees(options = {})
    with_scope :find => options do
      find(:all).collect(&:taggable).compact
    end
  end
  
  def self.find_by_category(category, options = {})
    with_scope :find => options do
      find(:all, :include => :tag, :conditions => ["tag_category_id = ?", category.id])
    end
  end

  def self.find_by_tag(tag, options = {})
    with_scope :find => options do
      find(:all, :include => :tag, :conditions => ["tag_id = ?", tag.id])
    end
  end

end
