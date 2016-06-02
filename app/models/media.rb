class Media < Tag

  NAME = ArchiveConfig.MEDIA_CATEGORY_NAME
  index_name Tag.index_name
  
  has_many :common_taggings, :as => :filterable
  has_many :fandoms, :through => :common_taggings, :source => :common_tag, :conditions => "type = 'Fandom'"
  
  def child_types
    ['Fandom']
  end 
  
  # The media tag for unwrangled fandoms
  def self.uncategorized
    if Rails.env == "test"
     return self.find_or_create_by_name(ArchiveConfig.MEDIA_UNCATEGORIZED_NAME)
    end
    Rails.cache.fetch("/MEDIA_UNCATEGORIZED_TAG/v1", expires_in: 1.day) do
      Tag.find(ArchiveConfig.MEDIA_UNCATEGORIZED_ID || 9971)
    end 
  end

  def add_association(tag) 
    tag.parents << self unless tag.parents.include?(self)
  end
end
