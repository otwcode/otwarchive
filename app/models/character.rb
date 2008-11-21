class Character < Tag

  NAME = ArchiveConfig.CHARACTER_CATEGORY_NAME

  before_save :add_fandom_to_parents
  
end
