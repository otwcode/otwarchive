class Character < Tag

  NAME = ArchiveConfig.CHARACTER_CATEGORY_NAME

  after_create :update_fandom

end
