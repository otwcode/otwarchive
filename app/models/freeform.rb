class Freeform < Tag

  NAME = ArchiveConfig.FREE_CATEGORY_NAME

  has_many :children, :through => :taggings, :source => :taggable, :source_type => 'Tag'

  after_create :update_fandom

  def fandom
    Fandom.find(self.fandom_id) if fandom_id
  end

  # assumes the only tags on a freeform tag are other freeform tags
  # if this changes will need a further filter
  def parent
    Tagging.find_by_taggable_id_and_taggable_type(self.id, 'Tag').tag
  end

end
