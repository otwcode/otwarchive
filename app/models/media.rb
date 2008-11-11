class Media < Tag

  NAME = ArchiveConfig.MEDIA_CATEGORY_NAME

  has_many :fandoms
end
