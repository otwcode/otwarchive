class Media < Tag

  NAME = ArchiveConfig.MEDIA_CATEGORY_NAME

  has_many :fandoms

  def children
    (super + fandoms).uniq.compact.sort
  end
end
