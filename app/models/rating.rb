class Rating < Tag

  NAME = ArchiveConfig.RATING_CATEGORY_NAME
  SINGULAR = true

  def self.setup_canonical(name, adult=false)
    tag = super(name)
    tag.update_attribute(:adult, adult)
    tag
  end
  
  DEFAULT = self.setup_canonical(ArchiveConfig.DEFAULT_RATING_TAG_NAME, true)
  EXPLICIT = self.setup_canonical(ArchiveConfig.EXPLICIT_RATING_TAG_NAME, true)
  MATURE = self.setup_canonical(ArchiveConfig.MATURE_RATING_TAG_NAME, true)
  TEEN = self.setup_canonical(ArchiveConfig.TEEN_RATING_TAG_NAME, false)
  GENERAL = self.setup_canonical(ArchiveConfig.GENERAL_RATING_TAG_NAME, false)

end

