class Genre < Tag

  NAME = ArchiveConfig.GENRE_CATEGORY_NAME

  has_many :freeforms
  
  after_create :update_fandom

  def fandom
    Fandom.find(self.fandom_id) if fandom_id
  end

end
