class Pairing < Tag

  NAME = ArchiveConfig.PAIRING_CATEGORY_NAME

  before_save :add_fandom_to_parents
  
  after_save :wrangle_characters

  def wrangle_characters(update_works=true)
    names = name.split('/')
    if names.size > 1
      names.each do |character_name|
        character = Character.find_or_create_by_name(character_name)
        if character
          character.update_attribute(:fandom_id, self.fandom_id) unless character.fandom
          character.wrangle_canonical(update_works) if self.canonical
          character.update_attribute(:wrangled, true) if self.wrangled
          self.wrangle_parent(character, update_works)
        end
      end
    end
  end

end
