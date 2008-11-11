class Character < Tag

  NAME = ArchiveConfig.CHARACTER_CATEGORY_NAME

  has_many :pairings, :through => :taggings, :source => :taggable, :source_type => 'Tag'
  after_create :update_fandom

end
