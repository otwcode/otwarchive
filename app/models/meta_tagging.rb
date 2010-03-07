class MetaTagging < ActiveRecord::Base
  belongs_to :meta_tag, :class_name => 'Tag'
  belongs_to :sub_tag, :class_name => 'Tag'
  
  validates_presence_of :meta_tag, :sub_tag
  validates_uniqueness_of :meta_tag_id, :scope => :sub_tag_id 
  
  before_create :add_filters, :inherit_meta_tags
  
  def validate
    unless self.meta_tag.class == self.sub_tag.class
      self.errors.add_to_base("Meta taggings can only exist between two tags of the same type.")
    end
  end
  
  # When you filter by the meta tag, you should get the works associated with the sub tag
  # but not vice versa
  def add_filters
    if self.meta_tag.canonical?
      self.sub_tag.filtered_works.each do |work|
        work.filters << self.meta_tag unless work.filters.include?(self.meta_tag)
      end
    end 
  end
  
  # The meta tag of my meta tag is my meta tag
  def inherit_meta_tags
    unless self.meta_tag.meta_tags.empty?
      self.meta_tag.meta_tags.each do |m|
        unless self.sub_tag.meta_tags.include?(m)
          MetaTagging.create(:meta_tag => m, :sub_tag => self.sub_tag, :direct => false) 
        end
      end
    end
    unless self.sub_tag.sub_tags.empty?
      self.sub_tag.sub_tags.each do |s|
        unless s.meta_tags.include?(self.meta_tag)
          MetaTagging.create(:meta_tag => self.meta_tag, :sub_tag => s, :direct => false) 
        end
      end
    end
  end
end