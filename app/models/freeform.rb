class Freeform < Tag

  NAME = ArchiveConfig.FREEFORM_CATEGORY_NAME
  
  COLLECTION_JOIN =  "INNER JOIN filter_taggings ON ( tags.id = filter_taggings.filter_id ) 
                      INNER JOIN works ON ( filter_taggings.filterable_id = works.id AND filter_taggings.filterable_type = 'Work') 
                      INNER JOIN collection_items ON ( works.id = collection_items.item_id AND collection_items.item_type = 'Work'
                                                       AND collection_items.collection_approval_status = '#{CollectionItem::APPROVED}'
                                                       AND collection_items.user_approval_status = '#{CollectionItem::APPROVED}' )" 
  
  # Types of tags to which a character tag can belong via common taggings or meta taggings
  def parent_types
    ['Fandom', 'MetaTag']
  end
  def child_types
    ['SubTag', 'Merger']
  end
  
  # Freeform tags for the tag index page - random
  def self.for_tag_cloud_random
    if no_fandom = Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME)
      no_fandom.children.with_count.canonical.first_class.by_type("Freeform").find(:all, :select => "DISTINCT tags.*, filter_counts.unhidden_works_count as count", :order => "RAND()", :limit => ArchiveConfig.TAGS_IN_CLOUD).sort
    end
  end
  
  # Freeform tags for the tag index page - popular
  def self.for_tag_cloud_popular
    if no_fandom = Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME)
      no_fandom.children.with_count.canonical.first_class.by_type("Freeform").find(:all, :select => "DISTINCT tags.*, filter_counts.unhidden_works_count as count", :order => "filter_counts.unhidden_works_count DESC", :limit => ArchiveConfig.TAGS_IN_CLOUD).sort
    end
  end

  named_scope :for_collections, lambda { |collections|
    {:select =>  "tags.*, count(tags.id) as count", 
    :joins => COLLECTION_JOIN,
    :conditions => ["collection_items.collection_id IN (?) 
                    AND works.posted = 1", collections.collect(&:id)], 
    :group => 'tags.id', 
    :order => 'name ASC'}
  }

  def characters
    parents.select {|t| t.is_a? Character}.sort
  end

  def relationships
    parents.select {|t| t.is_a? Relationship}.sort
  end

  def freeforms
    (parents + children).select {|t| t.is_a? Freeform}.sort
  end

  def fandoms
    parents.select {|t| t.is_a? Fandom}.sort
  end

  def medias
    parents.select {|t| t.is_a? Media}.sort
  end

end