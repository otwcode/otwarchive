class TagCategory < ActiveRecord::Base
  has_many :tags
  
  before_destroy :remove_me_from_my_tags
  
  def remove_me_from_my_tags
    self.tags.each do |t| 
      t.tag_category_id = TagCategory.default.id
      t.save
    end
  end
  
  def self.ambiguous
    find_by_name(ArchiveConfig.AMBIGUOUS_CATEGORY)
  end

  def self.default
    find_by_name(ArchiveConfig.DEFAULT_CATEGORY)
  end

  def self.official
    find_all_by_official(true, :order => 'required DESC')
  end
  
  def self.official_tags(category_name)
    category = find_by_name(category_name)
    return false unless category
    category.tags.map(&:visible).compact.sort
  end

end
