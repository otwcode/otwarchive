class Fandom < Tag

  NAME = ArchiveConfig.FANDOM_CATEGORY_NAME
  
  has_many :wrangling_assignments
  has_many :wranglers, :through => :wrangling_assignments, :source => :user 
  
  named_scope :by_media, lambda{|media| {:conditions => {:media_id => media.id}}}
  
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
  
  
  before_save :add_media_for_uncategorized
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

  def characters
    children.by_type('Character').by_name
  end

  def pairings
    children.by_type('Pairing').by_name
  end

  def freeforms
    children.by_type('Freeform').by_name
  end

  def fandoms
    (children + parents).select {|t| t.is_a? Fandom}.sort
  end

  def medias
    parents.by_type('Media').by_name
  end
  
  def add_association(tag)
    if tag.is_a?(Media)
      self.parents << tag unless self.parents.include?(tag)
      # Remove default media if another is added
      if self.medias.length > 1 && self.medias.include?(Media.uncategorized)
        self.medias.delete(Media.uncategorized)
      end
    else
      self.children << tag unless self.children.include?(tag)
    end   
  end
end