class Warning < Tag

  NAME = ArchiveConfig.WARNING_CATEGORY_NAME

  def self.warning_tags
    Set[ArchiveConfig.WARNING_DEFAULT_TAG_NAME,
        ArchiveConfig.WARNING_NONE_TAG_NAME,
        ArchiveConfig.WARNING_SOME_TAG_NAME,
        ArchiveConfig.WARNING_VIOLENCE_TAG_NAME,
        ArchiveConfig.WARNING_DEATH_TAG_NAME,
        ArchiveConfig.WARNING_NONCON_TAG_NAME,
        ArchiveConfig.WARNING_CHAN_TAG_NAME]
  end

  def self.warning?(warning)
    warning_tags.include? warning
  end
end
