class Fandom < Tag

  NAME = ArchiveConfig.FANDOM_CATEGORY_NAME
  
  has_many :wrangling_assignments
  has_many :wranglers, :through => :wrangling_assignments, :source => :user
  
  has_many :parents, :through => :common_taggings, :source => :filterable, :source_type => 'Tag', :after_remove => :check_media
  has_many :medias, :through => :common_taggings, :source => :filterable, :source_type => 'Tag', :conditions => "type = 'Media'"
  has_many :characters, :through => :child_taggings, :source => :common_tag, :conditions => "type = 'Character'"
  has_many :pairings, :through => :child_taggings, :source => :common_tag, :conditions => "type = 'Pairing'"
  has_many :freeforms, :through => :child_taggings, :source => :common_tag, :conditions => "type = 'Freeform'"
    
  named_scope :by_media, lambda{|media| {:conditions => {:media_id => media.id}}}
  named_scope :unwrangled, {:joins => "INNER JOIN `common_taggings` ON tags.id = common_taggings.common_tag_id", 
    :conditions => ["common_taggings.filterable_id = ? AND common_taggings.filterable_type = 'Tag'", Media.uncategorized.andand.id]}
    
  COLLECTION_JOIN =  "INNER JOIN filter_taggings ON ( tags.id = filter_taggings.filter_id ) 
                      INNER JOIN works ON ( filter_taggings.filterable_id = works.id AND filter_taggings.filterable_type = 'Work') 
                      INNER JOIN collection_items ON ( works.id = collection_items.item_id AND collection_items.item_type = 'Work'
                                                       AND collection_items.collection_approval_status = '#{CollectionItem::APPROVED}'
                                                       AND collection_items.user_approval_status = '#{CollectionItem::APPROVED}' )"

  named_scope :for_collection, lambda { |collection|
    {:select =>  "tags.*, count(tags.id) as count", 
    :joins => COLLECTION_JOIN,
    :conditions => ["collection_items.collection_id = ? 
                    AND works.posted = 1", collection.id], 
    :group => 'tags.id', 
    :order => 'name ASC'}    
  }
  
  named_scope :for_collections, lambda { |collections|
    {:select =>  "tags.*, count(tags.id) as count", 
    :joins => COLLECTION_JOIN,
    :conditions => ["collection_items.collection_id IN (?) 
                    AND works.posted = 1", collections.collect(&:id)], 
    :group => 'tags.id', 
    :order => 'name ASC'}
  }
  
  # when we don't need the counts, just a unique list
  named_scope :for_collections_without_count, lambda { |collections|
    {
      :select => "DISTINCT tags.*",
      :joins => COLLECTION_JOIN,
      :conditions => ["collection_items.collection_id IN (?) 
                      AND works.posted = 1", collections.collect(&:id)]
    } 
  }

  # This one can be '.count'ed, the others can't!
  named_scope :id_for_collections, lambda { |collections|
    {
      :select => "distinct tags.id",
      :joins => COLLECTION_JOIN,
      :conditions => ["collection_items.collection_id IN (?) 
                      AND works.posted = 1", collections.collect(&:id)]
    } 
  }
  
  # An association callback to add the default media if all others have been removed
  def check_media(media)
    self.add_media_for_uncategorized
  end  
  
  after_save :add_media_for_uncategorized
  def add_media_for_uncategorized
    if self.medias.empty?
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
  
  # Types of tags to which a character tag can belong via common taggings or meta taggings
  def parent_types
    ['Media', 'MetaTag']
  end
  def child_types
    ['Character', 'Pairing', 'Freeform', 'SubTag', 'Merger']
  end
  
  def add_association(tag)
    if tag.is_a?(Media)
      self.parents << tag unless self.parents.include?(tag)
      # Remove default media if another is added
      if self.medias.include?(Media.uncategorized)
        self.remove_association(Media.uncategorized)
      end
    else
      self.children << tag unless self.children.include?(tag)
    end   
  end
end