class TagSet < ActiveRecord::Base
  has_many :set_taggings, :dependent => :destroy
  has_many :tags, :through => :set_taggings
  
  named_scope :matching, lambda {|tag_set_to_match|
    {
      :select => "DISTINCT tag_sets.*",
      :joins => :tags,
      :group => 'tag_sets.id',
      :conditions => ["tag_sets.id != ? AND tags.id in (?)", tag_set_to_match.id, tag_set_to_match.tags],
      :order => "count(tags.id) desc"
    }
  }
  
  def exact_match?(another)
    self.tags == another.tags
  end
    
  def no_match?(another)
    (self.tags & another.tags).empty? && !self.tags.empty?
  end
  
  def partial_match?(another)
    !(self.tags & another.tags).empty?
  end

  def match_with_type?(another, type)
    (self.tags.with_type(type) & another.tags.with_type(type)) == self.tags.with_type(type)
  end
  
  def partial_match_with_type?(another, type)
    !(self.tags.with_type(type) & another.tags.with_type(type)).empty?
  end
  
  def matching_tags(another)
    self.tags & another.tags
  end
  
  def matching_tags_with_type(another)
    self.tags.with_type(type) & another.tags.with_type(type)
  end
  
end
