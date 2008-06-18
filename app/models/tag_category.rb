class TagCategory < ActiveRecord::Base
  has_many :tags
  
  def self.official
    find_all_by_official(true, :order => 'required DESC')
  end
  
  def self.official_tags(category_name)
    category = find_by_name(category_name)
    return false unless category
    category.tags.map(&:visible).compact.sort
  end

end
