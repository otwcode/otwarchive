class Freeform < Tag

  NAME = ArchiveConfig.FREEFORM_CATEGORY_NAME
  
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
      no_fandom.children.with_count.canonical.first_class.by_type("Freeform").random.limit(ArchiveConfig.TAGS_IN_CLOUD)
    end
  end
  
  # Freeform tags for the tag index page - popular
  def self.for_tag_cloud_popular
    if no_fandom = Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME)
      no_fandom.children.canonical.first_class.by_type("Freeform").popular.limit(ArchiveConfig.TAGS_IN_CLOUD)
    end
  end

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