class Media < Tag
  NAME = ArchiveConfig.MEDIA_CATEGORY_NAME

  has_many :common_taggings, as: :filterable
  has_many :fandoms, -> { where(type: 'Fandom') }, through: :common_taggings, source: :common_tag

  def child_types
    ['Fandom']
  end

  # The media tag for unwrangled fandoms
  def self.uncategorized
    tag = self.find_or_create_by_name(ArchiveConfig.MEDIA_UNCATEGORIZED_NAME)
    tag.update(canonical: true) unless tag.canonical
    tag
  end

  # The list of media used for the menu on every page. All media except "No
  # Media" and "Uncategorized Fandoms" are listed in order, and then
  # "Uncategorized Fandoms" is tacked onto the list at the end.
  def self.for_menu
    by_name.where.not(
      name: [ArchiveConfig.MEDIA_UNCATEGORIZED_NAME,
             ArchiveConfig.MEDIA_NO_TAG_NAME]
    ).to_a + [uncategorized]
  end
end
