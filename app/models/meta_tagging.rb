# Relationships between meta and sub tags
# Meta tags represent a superset of sub tags
class MetaTagging < ApplicationRecord
  belongs_to :meta_tag, class_name: 'Tag'
  belongs_to :sub_tag, class_name: 'Tag'

  validates_presence_of :meta_tag, :sub_tag, message: "does not exist."
  validates_uniqueness_of :meta_tag_id,
                          scope: :sub_tag_id,
                          message: "has already been added (possibly as an indirect meta tag)."

  before_create :add_filters, :inherit_meta_tags
  after_create :expire_caching
  after_destroy :expire_caching

  validate :meta_tag_validation
  def meta_tag_validation
    if self.meta_tag && self.sub_tag
      unless self.meta_tag.class == self.sub_tag.class
        self.errors.add(:base, "Meta taggings can only exist between two tags of the same type.")
      end
      unless self.meta_tag.canonical? && self.sub_tag.canonical
        self.errors.add(:base, "Meta taggings can only exist between canonical tags.")
      end
      if self.meta_tag == self.sub_tag
        self.errors.add(:base, "A tag can't be its own meta tag.")
      end
      if self.meta_tag.meta_tags.include?(self.sub_tag)
        self.errors.add(:base, "A meta tag can't be its own grandpa.")
      end
    end
  end

  # When you filter by the meta tag, you should get the works associated with the sub tag
  # but not vice versa
  def add_filters
    if self.meta_tag.canonical?
      self.sub_tag.async(:inherit_meta_filters, self.meta_tag.id)
    end
  end

  # The meta tag of my meta tag is my meta tag
  def inherit_meta_tags
    unless self.meta_tag.meta_tags.empty?
      self.meta_tag.meta_tags.each do |m|
        if self.sub_tag.meta_tags.include?(m)
          meta_tagging = self.sub_tag.meta_taggings.where(meta_tag_id: m.id).first
          meta_tagging.update_attribute(:direct, false)
        else
          MetaTagging.create!(meta_tag: m, sub_tag: self.sub_tag, direct: false)
        end
      end
    end
    unless self.sub_tag.sub_tags.empty?
      self.sub_tag.sub_tags.each do |s|
        if s.meta_tags.include?(self.meta_tag)
          meta_tagging = s.meta_taggings.where(meta_tag_id: self.meta_tag.id).first
          meta_tagging.update_attribute!(:direct, false)
        else
          MetaTagging.create!(meta_tag: self.meta_tag, sub_tag: s, direct: false)
        end
      end
    end
  end

  def expire_caching
    self.meta_tag&.update_works_index_timestamp!
  end

  # Go through all MetaTaggings and destroy the invalid ones.
  def self.destroy_invalid
    includes(:sub_tag, meta_tag: :meta_tags).find_each do |mt|
      valid = mt.valid?

      # Let callers do something on each iteration.
      yield mt, valid if block_given?

      next if valid

      if mt.sub_tag && mt.meta_tag
        # We use this method instead of mt.destroy because we want to trigger the
        # before_remove callbacks on mt.sub_tag, thus ensuring that we clean up
        # the filter_taggings associated with this MetaTagging.
        mt.sub_tag.meta_tags.delete(mt.meta_tag)
      else
        # But in this case, one of the two tags is missing, so we can only
        # properly delete the meta tagging by calling mt.destroy:
        mt.destroy
      end
    end
  end
end
