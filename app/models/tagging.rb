class Tagging < ActiveRecord::Base
  belongs_to :tag, :counter_cache => true
  belongs_to :taggable, :polymorphic => true
  
  validates_presence_of :tag, :taggable
  before_create :check_for_synonyms
  before_destroy :delete_unused_tags
  after_create :update_fandom

  # Tag with canonical synonym instead, if it exists
  def check_for_synonyms
    synonym = self.tag.synonym
    self.tag = synonym if synonym
  end 
  
  # Gets rid of unwrangled tags that aren't tagging anything else
  def delete_unused_tags
    tag.destroy if (tag.unwrangled? && tag.taggings == [self])
  end

  def update_fandom
    tag.update_fandom if tag.unwrangled?
  end
end
