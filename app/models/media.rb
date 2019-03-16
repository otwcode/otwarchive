class Media < Tag
  include ActiveModel::ForbiddenAttributesProtection

  NAME = ArchiveConfig.MEDIA_CATEGORY_NAME

  has_many :common_taggings, as: :filterable
  has_many :fandoms, -> { where(type: 'Fandom') }, through: :common_taggings, source: :common_tag

  def child_types
    ['Fandom']
  end

  # The media tag for unwrangled fandoms
  def self.uncategorized
    self.find_or_create_by_name(ArchiveConfig.MEDIA_UNCATEGORIZED_NAME)
  end

  def add_association(tag)
    tag.parents << self unless tag.parents.include?(self)
  end
end
