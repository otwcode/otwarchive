class Freeform < Tag

  NAME = ArchiveConfig.FREE_CATEGORY_NAME

  belongs_to :genre
  
  after_create :update_fandom

  # freeform tags aren't typically synonyms
  # instead they get added to genres.
  def add_to_genre(tag)
    return false unless tag.is_a?(Genre)
    tag.update_attribute(:canonical, true) unless tag.canonical
    self.update_attribute(:genre_id, tag.id) 
    for work in self.works
      work.genres << tag unless work.genres.include?(tag)
    end
    return true
  end

end
