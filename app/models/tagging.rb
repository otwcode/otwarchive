class Tagging < ActiveRecord::Base
  belongs_to :tagger, :polymorphic => true, :counter_cache => true
  belongs_to :taggable, :polymorphic => true

  validates_presence_of :tagger, :taggable
  before_destroy :remove_filter_tagging
  before_save :add_filter_taggings
  
  def add_filter_taggings
    if self.tagger && self.taggable.is_a?(Work)
      self.taggable.add_filter_tagging(self.tagger)
      filter = self.tagger.filter
      unless filter.nil? || filter.meta_tags.empty?
        filter.meta_tags.each { |m| self.taggable.add_filter_tagging(m, true) }
      end
    end
    return true    
  end
  
  def remove_filter_tagging
    if self.tagger && self.taggable.is_a?(Work)
      self.taggable.remove_filter_tagging(self.tagger)
    end
    return true   
  end

  def self.find_by_tag(taggable, tag)
    Tagging.find_by_tagger_id_and_taggable_id_and_tagger_type_and_taggable_type(tag.id, taggable.id, 'Tag', taggable.class.name)
  end
end