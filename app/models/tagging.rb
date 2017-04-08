class Tagging < ActiveRecord::Base
  belongs_to :tagger, polymorphic: true
  belongs_to :taggable, polymorphic: true, touch: true

  validates_presence_of :tagger, :taggable
  before_destroy :remove_filter_tagging
  before_save :add_filter_taggings

  # Tell the tag that the taggings count may have been updated.
  after_create :update_taggings_count
  after_destroy :update_taggings_count

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

  # Tell the tag that the taggings count may have been updated, and the
  # taggings count should be loaded into the cache if it isn't already.
  def update_taggings_count
    tagger.update_tag_cache unless tagger.blank? || tagger.destroyed?
  end
end
