class Fandom < Tag

  NAME = ArchiveConfig.FANDOM_CATEGORY_NAME
  index_name Tag.index_name
  
  has_many :wrangling_assignments
  has_many :wranglers, :through => :wrangling_assignments, :source => :user
  
  has_many :parents, :through => :common_taggings, :source => :filterable, :source_type => 'Tag', :after_remove => :check_media
  has_many :medias, :through => :common_taggings, :source => :filterable, :source_type => 'Tag', :conditions => "type = 'Media'"
  has_many :characters, :through => :child_taggings, :source => :common_tag, :conditions => "type = 'Character'"
  has_many :relationships, :through => :child_taggings, :source => :common_tag, :conditions => "type = 'Relationship'"
  has_many :freeforms, :through => :child_taggings, :source => :common_tag, :conditions => "type = 'Freeform'"
    

  scope :by_media, lambda {|media| where(:media_id => media.id)}

  def self.unwrangled
    joins(:common_taggings).
    where("unwrangleable = 0 AND common_taggings.filterable_id = ? AND common_taggings.filterable_type = 'Tag'", Media.uncategorized.try(:id))
  end
    
  # An association callback to add the default media if all others have been removed
  def check_media(media)
    self.add_media_for_uncategorized
  end  
  
  after_save :add_media_for_uncategorized
  def add_media_for_uncategorized
    if self.medias.empty? && self.type == "Fandom" # type could be something else if the tag is in the process of being re-categorised (re-sorted)
      self.parents << Media.uncategorized
    end
    true    
  end
  
  before_update :check_wrangling_status
  def check_wrangling_status
    if self.canonical_changed? && !self.canonical?
      if !self.canonical? && self.merger_id
        self.merger.wranglers = (self.wranglers + self.merger.wranglers).uniq
      end
      self.wranglers = []     
    end
  end
  
  # Types of tags to which a fandom tag can belong via common taggings or meta taggings
  def parent_types
    ['Media', 'MetaTag']
  end
  def child_types
    ['Character', 'Relationship', 'Freeform', 'SubTag', 'Merger']
  end
  
  def add_association(tag)
    if tag.is_a?(Media)
      self.parents << tag unless self.parents.include?(tag)
      # Remove default media if another is added
      if self.medias.include?(Media.uncategorized)
        self.remove_association(Media.uncategorized.id)
      end
    else
      self.children << tag unless self.children.include?(tag)
    end   
  end
end
