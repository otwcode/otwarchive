class Tagging < ActiveRecord::Base
  belongs_to :tagger, polymorphic: true
  belongs_to :taggable, polymorphic: true, touch: true

  validates_presence_of :tagger, :taggable
  before_destroy :remove_filter_tagging
  before_save :add_filter_taggings

  # When we create or destroy a tagging, it may change the taggings count.
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

  # Most of the time, we don't need the taggings_count_cache stored in the
  # database to be perfectly accurate. But because of the way Tag.in_use is
  # defined and used, the difference between a value of 0 and a value of 1 is
  # important. So we make sure to poke the taggings_count cache every time we
  # create or destroy a tagging. If it's a large tag, it'll fall back on the
  # cached value. If it's a small tag, it'll recompute -- and make sure that it
  # handles the transition from 0 uses to 1 use properly.
  def update_taggings_count
    tagger.update_tag_cache unless tagger.blank? || tagger.destroyed?
  end
end
