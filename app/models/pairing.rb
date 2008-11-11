class Pairing < Tag

  NAME = ArchiveConfig.PAIRING_CATEGORY_NAME

  after_save :update_characters
  after_create :update_fandom

  def update_characters
     name.split('/').each do |character_name|
       character = Character.find_or_create_by_name(character_name)
       character.update_attribute(:canonical, true) if canonical 
       character.pairings << self unless character.pairings.include? self
     end 
  end

  # assumes the only tags on a pairing are character tags
  # if this changes will need a further filter
  def characters
    Tagging.find_all_by_taggable_id_and_taggable_type(self.id, 'Tag').map(&:tag)
  end
end
