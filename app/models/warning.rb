class Warning < Tag

  NAME = ArchiveConfig.WARNING_CATEGORY_NAME

  DEFAULT = self.setup_canonical(ArchiveConfig.DEFAULT_WARNING_TAG_NAME)
  NONE = self.setup_canonical(ArchiveConfig.NO_WARNING_TAG_NAME)
  SOME = self.setup_canonical(ArchiveConfig.SOME_WARNING_TAG_NAME)
  VIOLENCE = self.setup_canonical(ArchiveConfig.VIOLENCE_WARNING_TAG_NAME)
  DEATHFIC = self.setup_canonical(ArchiveConfig.DEATHFIC_WARNING_TAG_NAME)
  NONCON = self.setup_canonical(ArchiveConfig.NONCON_WARNING_TAG_NAME)
  CHAN = self.setup_canonical(ArchiveConfig.CHAN_WARNING_TAG_NAME)
  
end

