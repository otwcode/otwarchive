class Tagging < ActiveRecord::Base
  belongs_to :tagger, :polymorphic => true, :counter_cache => true
  belongs_to :taggable, :polymorphic => true

  validates_presence_of :tagger, :taggable
  before_destroy :delete_unused_tags
  before_save :add_filter_taggings
  
  def add_filter_taggings
    if self.tagger && self.taggable.is_a?(Work)
      self.taggable.add_filter_tagging(self.tagger)
    end
    return true    
  end

  # Gets rid of unwrangled tags that aren't tagging anything else
  def delete_unused_tags
    return unless tagger
    tagger.destroy if (tagger.unwrangled && tagger.taggings == [self])
  end

  def self.find_by_tag(taggable, tag)
    Tagging.find_by_tagger_id_and_taggable_id_and_tagger_type_and_taggable_type(tag.id, taggable.id, 'Tag', taggable.class.name)
  end
end
