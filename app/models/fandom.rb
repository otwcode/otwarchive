class Fandom < Tag

  NAME = ArchiveConfig.FANDOM_CATEGORY_NAME

  has_many :characters
  has_many :pairings
  has_many :freeforms

  def reassign_to_canonical
    super
    characters.each {|t| t.update_attribute(:fandom_id, synonym.id)}
    pairings.each {|t| t.update_attribute(:fandom_id, synonym.id)}
    freeforms.each {|t| t.update_attribute(:fandom_id, synonym.id)}
  end
  
  def media
    Media.find_by_id(self.media_id)
  end
  
  def unwrangled?
    return false if (self.canonical && self.media)
    return false if (!self.canonical && self.synonym)
    return false if self.banned
    return true
  end
end

