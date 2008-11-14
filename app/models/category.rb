class Category < Tag

  NAME = ArchiveConfig.CATEGORY_CATEGORY_NAME

  HET = self.setup_canonical(ArchiveConfig.HET_CATEGORY_TAG_NAME)
  SLASH = self.setup_canonical(ArchiveConfig.SLASH_CATEGORY_TAG_NAME)
  FEMSLASH = self.setup_canonical(ArchiveConfig.FEMSLASH_CATEGORY_TAG_NAME)
  GEN = self.setup_canonical(ArchiveConfig.GEN_CATEGORY_TAG_NAME)
  MULTI = self.setup_canonical(ArchiveConfig.MULTI_CATEGORY_TAG_NAME)
  OTHER = self.setup_canonical(ArchiveConfig.OTHER_CATEGORY_TAG_NAME)

end

