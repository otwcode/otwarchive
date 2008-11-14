class Pairing < Tag

  NAME = ArchiveConfig.PAIRING_CATEGORY_NAME
  
  after_save :update_characters
  after_create :update_fandom

  has_many :taggings, :as => :taggable
  has_many :characters, :as => :taggable, :through => :taggings, :source => :tagger, :source_type => 'Character'

  def update_characters
    characters = name.split('/')

    characters.each do |character_name|
      character = Character.find_or_create_by_name(character_name.strip.squeeze(" "))
      if self.canonical? 
        character.update_attribute(:canonical, true)
        if self.fandom
          character.update_attribute(:fandom_id, self.fandom_id) if self.fandom.canonical?
        end
      end
      self.characters << character unless self.characters.include?(character)
    end if characters.size > 1

    return self.characters
  end
  
end
