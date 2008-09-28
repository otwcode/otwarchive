begin
  ActiveRecord::Base.connection  # if we have no database fall through to rescue
  WARNING_TAG_CATEGORY = TagCategory.find_or_create_official_category(ArchiveConfig.WARNING_CATEGORY_NAME, :required => true)
  RATING_TAG_CATEGORY = TagCategory.find_or_create_official_category(ArchiveConfig.RATING_CATEGORY_NAME, :required => true, :exclusive => true)
  FANDOM_TAG_CATEGORY = TagCategory.find_or_create_official_category(ArchiveConfig.FANDOM_CATEGORY_NAME, :required => true)
  CATEGORY_TAG_CATEGORY = TagCategory.find_or_create_official_category(ArchiveConfig.CATEGORY_CATEGORY_NAME, :required => false, :exclusive => true)
  DEFAULT_TAG_CATEGORY = TagCategory.find_or_create_official_category('default', :display_name => 'Tags'.t)
  AMBIGUOUS_TAG_CATEGORY = TagCategory.find_or_create_official_category('ambiguous', :display_name => 'Ambiguous'.t)

  OFFICIAL_TAG_CATEGORIES = TagCategory.official

  DEFAULT_WARNING_TAG = Tag.find_or_create_canonical_tag(ArchiveConfig.DEFAULT_WARNING_TAG_NAME, WARNING_TAG_CATEGORY)
  NO_WARNING_TAG = Tag.find_or_create_canonical_tag(ArchiveConfig.NO_WARNING_TAG_NAME, WARNING_TAG_CATEGORY)

  DEFAULT_RATING_TAG = Tag.find_or_create_canonical_tag(ArchiveConfig.DEFAULT_RATING_TAG_NAME, RATING_TAG_CATEGORY)
  EXPLICIT_RATING_TAG = Tag.find_or_create_canonical_tag(ArchiveConfig.EXPLICIT_RATING_TAG_NAME, RATING_TAG_CATEGORY)
  MATURE_RATING_TAG = Tag.find_or_create_canonical_tag(ArchiveConfig.MATURE_RATING_TAG_NAME, RATING_TAG_CATEGORY)
  TEEN_RATING_TAG = Tag.find_or_create_canonical_tag(ArchiveConfig.TEEN_RATING_TAG_NAME, RATING_TAG_CATEGORY)
  GENERAL_RATING_TAG = Tag.find_or_create_canonical_tag(ArchiveConfig.GENERAL_RATING_TAG_NAME, RATING_TAG_CATEGORY)

  HET_CATEGORY_TAG = Tag.find_or_create_canonical_tag(ArchiveConfig.HET_CATEGORY_TAG_NAME, CATEGORY_TAG_CATEGORY)
  SLASH_CATEGORY_TAG = Tag.find_or_create_canonical_tag(ArchiveConfig.SLASH_CATEGORY_TAG_NAME, CATEGORY_TAG_CATEGORY)
  FEMSLASH_CATEGORY_TAG = Tag.find_or_create_canonical_tag(ArchiveConfig.FEMSLASH_CATEGORY_TAG_NAME, CATEGORY_TAG_CATEGORY)
  GEN_CATEGORY_TAG = Tag.find_or_create_canonical_tag(ArchiveConfig.GEN_CATEGORY_TAG_NAME, CATEGORY_TAG_CATEGORY)
  MULTI_CATEGORY_TAG = Tag.find_or_create_canonical_tag(ArchiveConfig.MULTI_CATEGORY_TAG_NAME, CATEGORY_TAG_CATEGORY)
  OTHER_CATEGORY_TAG = Tag.find_or_create_canonical_tag(ArchiveConfig.OTHER_CATEGORY_TAG_NAME, CATEGORY_TAG_CATEGORY)

  OFFICIAL_WARNING_TAGS = Tag.by_category(WARNING_TAG_CATEGORY).canonical
  OFFICIAL_RATING_TAGS =  Tag.by_category(RATING_TAG_CATEGORY).canonical
  OFFICIAL_FANDOM_TAGS =  Tag.by_category(FANDOM_TAG_CATEGORY).canonical
  OFFICIAL_CATEGORY_TAGS = Tag.by_category(CATEGORY_TAG_CATEGORY).canonical  
rescue
  
end
