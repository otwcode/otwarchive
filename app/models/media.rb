class Media < Tag

  NAME = ArchiveConfig.MEDIA_CATEGORY_NAME

  has_many :fandoms

  def children
    (super + fandoms).uniq.compact.sort
  end
  
  # The media tag for unwrangled fandoms
  def self.uncategorized
    self.find_by_name(ArchiveConfig.MEDIA_UNCATEGORIZED_NAME)
  end
end
