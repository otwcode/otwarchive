class Media < Tag

  NAME = ArchiveConfig.MEDIA_CATEGORY_NAME

  has_many :fandoms

  def wrangle_merger(tag, update_works=true)
    super(tag, update_works)
    fandoms.each {|t| t.update_attribute(:media_id, tag.id)}
  end

  def children
    (super + fandoms).uniq.compact.sort
  end
end
