class Freeform < Tag

  NAME = ArchiveConfig.FREEFORM_CATEGORY_NAME

  before_save :add_fandom_to_parents
  
end
