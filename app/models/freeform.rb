class Freeform < Tag

  NAME = ArchiveConfig.FREE_CATEGORY_NAME

  after_create :update_fandom

  def fandom
    Fandom.find(self.fandom_id) if fandom_id
  end

  def genre
    Genre.find(self.genre_id) if genre_id
  end


end
