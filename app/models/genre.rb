class Genre < Tag

  NAME = ArchiveConfig.GENRE_CATEGORY_NAME

  has_many :freeforms
  
  def fandom
    Fandom.find(self.fandom_id) if fandom_id
  end

  def self.create_from_freeform(tag)
    return unless tag.is_a?(Freeform)
    genre_tag = Genre.find_or_create_by_name(tag.name)
    genre_tag.update_attribute(:canonical, true)
    tag.add_to_genre(genre_tag)
    return genre_tag
  end
end
