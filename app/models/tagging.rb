class Tagging < ActiveRecord::Base
  belongs_to :tag, :counter_cache => true
  belongs_to :tag_relationship
  belongs_to :taggable, :polymorphic => true
  
  validates_presence_of :tag, :taggable
  validates_uniqueness_of :tag_relationship_id, :scope => [:tag_id, :taggable_id, :taggable_type]

  # Make the relationship bidirectional if the tag_relationship is reciprocal
  attr_accessor :final
  after_save :duplicate_inverted
  after_destroy :destroy_inverted


  def valid_tag
    return tag if tag && !tag.banned?
  end
  
  def self.tagees(options = {})
    with_scope :find => options do
      find(:all).collect(&:taggable).compact
    end
  end
  
  def self.find_by_category(category, options = {})
    with_scope :find => options do
      find(:all, :include => :tag, :conditions => ["tags.tag_category_id = ?", category.id])
    end
  end

  def self.find_by_tag(tag, options = {})
    with_scope :find => options do
      find(:all, :include => :tag, :conditions => ["tags.id = ?", tag.id])
    end
  end

  protected

    # Create an inverted version of this record if the tag_relationship is reciprocal (unless one already exists)
    def duplicate_inverted
      return true if self.final
      if tag_relationship
        if tag_relationship.reciprocal?
          Tagging.send(:with_exclusive_scope, :find => {}, :create => {}) do
            unless Tagging.exists? :tag_id => taggable_id, :taggable_id => tag_id, :taggable_type => 'Tag'
              Tagging.create :final => true, :tag_id => taggable_id, :taggable_id => tag_id, :taggable_type => 'Tag', :tag_relationship_id => tag_relationship.id
            end
          end
        end
        
      end
    end

    # Remove the inverted version of this object if the tag_relationship is reciprocal
    def destroy_inverted
      if tag_relationship
        if tag_relationship.reciprocal?
          if Tagging.exists? :tag_id => self.taggable_id, :taggable_id => self.tag_id, :taggable_type => 'Tag'
            Tagging.destroy_all :tag_id => self.taggable_id, :taggable_id =>self.tag_id, :taggable_type => 'Tag'
          end
        end
      end
    end

end
