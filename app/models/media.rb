class Media < Tag

  NAME = ArchiveConfig.MEDIA_CATEGORY_NAME

  has_many :fandoms

  def wrangle_merger(tag)
    super
    fandoms.each {|t| t.wrangle_merger(tag)}
  end

end
