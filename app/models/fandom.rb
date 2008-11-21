class Fandom < Tag

  NAME = ArchiveConfig.FANDOM_CATEGORY_NAME
  
  before_save :add_media_to_parents
  def add_media_to_parents
    self.parents << self.media rescue nil
    return true
  end
  
end

