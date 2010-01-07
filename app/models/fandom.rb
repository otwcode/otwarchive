class Fandom < Tag

  NAME = ArchiveConfig.FANDOM_CATEGORY_NAME

  named_scope :by_media, lambda{|media| {:conditions => {:media_id => media.id}}}
  named_scope :no_parent, :conditions => {:media_id => Media.uncategorized.andand.id}
  
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
    if self.media_id.nil?
      uncategorized = Media.uncategorized
      other_media = self.medias - [uncategorized]
      if !other_media.empty?
        self.media = other_media.first
      else
        self.media = uncategorized
      end
    end    
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

end


