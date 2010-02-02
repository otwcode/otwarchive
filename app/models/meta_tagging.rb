class MetaTagging < ActiveRecord::Base
  belongs_to :meta_tag, :class_name => 'Tag'
  belongs_to :sub_tag, :class_name => 'Tag'
  
  validates_presence_of :meta_tag, :sub_tag  
  
  before_create :add_filters, :inherit_meta_tags
  
  # When you filter by the meta tag, you should get the works associated with the sub tag
  # but not vice versa
  def add_filters
    unless self.sub_tag.has_meta_tags?
      self.sub_tag.toggle!(:has_meta_tags)
    end
    if self.meta_tag.canonical?
      self.sub_tag.filtered_works.each do |work|
        work.filters << self.meta_tag unless work.filters.include?(self.meta_tag)
      end
    end 
  end
  
  # The meta tag of my meta tag is my meta tag
  def inherit_meta_tags
    unless self.meta_tag.meta_tags.empty?
      self.meta_tag.meta_tags.each { |m| self.sub_tag.meta_tags << m unless self.sub_tag.meta_tags.include?(m) }
    end
  end   
end