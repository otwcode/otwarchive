class TagCategory < ActiveRecord::Base
  has_many :tags
  
  validates_uniqueness_of :name
  
  before_destroy :remove_me_from_my_tags
  
  named_scope :ordered, :order => 'official, required DESC, exclusive DESC'
  named_scope :official, :conditions => {:official => true}, :order => 'official, required DESC, exclusive DESC'
  named_scope :required, :conditions => {:required => true}
  named_scope :exclusive, :conditions => {:exclusive => true}

  def remove_me_from_my_tags
    self.tags.each do |t| 
      t.tag_category_id = nil
      t.save
    end
  end

  # return tag categories including tags
  def self.official_with_tags
    find(:all, :conditions => {:official => true }, :order => 'official, required DESC, exclusive DESC',
         :include => :tags )
  end
  
  def self.official_tags(category_name)
    category = find_by_name(category_name)
    return [] unless category
    category.tags.map(&:official).compact.sort
  end
  
  def display_name
    display_name? ? super : name
  end

  def self.find_or_create_official_category(category_name, options = {})
    find_by_name(category_name) || 
      self.create({ :name => category_name.downcase, :official => true, :display_name => category_name.capitalize.t }.merge(options))
  end
	
	WARNING = TagCategory.find_or_create_official_category(ArchiveConfig.WARNING_CATEGORY_NAME, {:required => true})
  RATING = TagCategory.find_or_create_official_category(ArchiveConfig.RATING_CATEGORY_NAME, {:required => true, :exclusive => true})
  FANDOM = TagCategory.find_or_create_official_category(ArchiveConfig.FANDOM_CATEGORY_NAME, {:required => true})
  CATEGORY = TagCategory.find_or_create_official_category(ArchiveConfig.CATEGORY_CATEGORY_NAME, {:required => false, :exclusive => true})
  PAIRING = TagCategory.find_or_create_official_category(ArchiveConfig.PAIRING_CATEGORY_NAME)
  CHARACTER = TagCategory.find_or_create_official_category(ArchiveConfig.CHARACTER_CATEGORY_NAME)
  DEFAULT = TagCategory.find_or_create_official_category(ArchiveConfig.DEFAULT_CATEGORY_NAME, {:display_name => 'Tags'.t})
  AMBIGUOUS = TagCategory.find_or_create_official_category(ArchiveConfig.AMBIGUOUS_CATEGORY_NAME, {:display_name => 'Ambiguous'.t})
	CATEGORIES = [WARNING, RATING, FANDOM, CATEGORY, PAIRING, CHARACTER, DEFAULT, AMBIGUOUS]
	OFFICIAL = self.official - [AMBIGUOUS]
end
