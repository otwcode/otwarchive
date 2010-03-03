class TagSet < ActiveRecord::Base
  has_many :set_taggings, :dependent => :destroy
  has_many :tags, :through => :set_taggings

  validate :all_tags_must_be_canonical  
  def all_tags_must_be_canonical
    uncanonical_tags = self.tags.reject {|tag| tag.canonical}
    unless uncanonical_tags.empty?
      errors.add_to_base(t('tag_set.must_be_canonical', 
                :default => "The following tags aren't canonical and can't be used: {{taglist}}", 
                :taglist => uncanonical_tags.collect(&:name).join(", ") ))
    end
  end

  named_scope :matching, lambda {|tag_set_to_match|
    {
      :select => "DISTINCT tag_sets.*",
      :joins => :tags,
      :group => 'tag_sets.id',
      :conditions => ["tag_sets.id != ? AND tags.id in (?)", tag_set_to_match.id, tag_set_to_match.tags],
      :order => "count(tags.id) desc"
    }
  }
  
  def tagnames=(taglist)
    tags_to_set = taglist.split(ArchiveConfig.DELIMITER_FOR_INPUT).collect {|tagname| Tag.canonical.find_by_name(tagname.squish)}
    self.tags = tags_to_set
  end
  
  def tagnames
    self.tags.collect(&:name).join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
  end
  
  def has_tag?(tag)
    self.tags.include?(tag)
  end

  # this code defines the functions fandom_tagnames=/fandom_tagnames, character_tagnames=... etc
  # to set the tags by separate type`
  # because all of these are the same, I'm using define_method to avoid creating a
  # ton of almost duplicate functions
  %w(fandom character pairing rating warning category freeform).each do |type|
    define_method("#{type}_tagnames=") do |taglist|
      taglist = (taglist.kind_of?(String) ? taglist.split(ArchiveConfig.DELIMITER_FOR_INPUT) : taglist)
      new_tags = taglist.map {|tagname| (type.classify.constantize).find_or_create_by_name(tagname.squish)}
      old_tags = self.with_type(type.classify)
      tags_to_set = (self.tags - old_tags + new_tags).compact.uniq
      self.tags = tags_to_set
    end
    
    define_method("#{type}_tagnames") do
      self.with_type(type.classify).collect(&:name).join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
    end    
  end
  
  def with_type(type)
    return self.tags.with_type(type)
  end

  def empty?
    self.tags.empty?
  end
  
  def exact_match?(another)
    self.tags == another.tags
  end
    
  def no_match?(another)
    (self.tags & another.tags).empty? && !self.tags.empty?
  end
  
  def partial_match?(another)
    !(self.tags & another.tags).empty?
  end
  
  def is_subset_of?(another, type=nil)
    if type
      (self.tags.with_type(type) & another.tags.with_type(type)) == self.tags.with_type(type)
    else
      (self.tags & another.tags) == self.tags
    end
  end
  
  def is_superset_of?(another, type=nil)
    if type
      (self.tags.with_type(type) & another.tags.with_type(type)) == another.tags.with_type(type)
    else
      (self.tags & another.tags) == another.tags
    end
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
