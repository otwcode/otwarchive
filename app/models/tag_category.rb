class TagCategory < ActiveRecord::Base
  has_many :tags
  
  validates_uniqueness_of :name
  
  before_destroy :remove_me_from_my_tags
  
  named_scope :ordered, :order => 'official, required DESC, exclusive DESC'
  named_scope :official, :conditions => {:official => true}, :order => 'official, required DESC, exclusive DESC'
  named_scope :required, :conditions => {:required => true}
  named_scope :exclusive, :conditions => {:exclusive => true}

  @@warning_tag_category = nil
  @@rating_tag_category = nil
  @@fandom_tag_category = nil
  @@category_tag_category = nil
  @@pairing_tag_category = nil
  @@character_tag_category = nil
  @@default_tag_category = nil
  @@ambiguous_tag_category = nil
  @@official_tag_categories = []

  def self.official_tag_categories; @@official_tag_categories.empty? ? @@official_tag_categories = self.official : @@official_tag_categories ; end
  def self.warning_tag_category; @@warning_tag_category || @@warning_tag_category = TagCategory.find_or_create_official_category(ArchiveConfig.WARNING_CATEGORY_NAME, :required => true); end
  def self.rating_tag_category; @@rating_tag_category || @@rating_tag_category = TagCategory.find_or_create_official_category(ArchiveConfig.RATING_CATEGORY_NAME, :required => true, :exclusive => true); end
  def self.fandom_tag_category; @@fandom_tag_category || @@fandom_tag_category = TagCategory.find_or_create_official_category(ArchiveConfig.FANDOM_CATEGORY_NAME, :required => true); end
  def self.category_tag_category; @@category_tag_category || @@category_tag_category = TagCategory.find_or_create_official_category(ArchiveConfig.CATEGORY_CATEGORY_NAME, :required => false, :exclusive => true); end
  def self.pairing_tag_category; @@pairing_tag_category || @@pairing_tag_category = TagCategory.find_or_create_official_category(ArchiveConfig.PAIRING_CATEGORY_NAME); end
  def self.character_tag_category; @@character_tag_category || @@character_tag_category = TagCategory.find_or_create_official_category(ArchiveConfig.CHARACTER_CATEGORY_NAME); end
  def self.default_tag_category; @@default_tag_category || @@default_tag_category = TagCategory.find_or_create_official_category(ArchiveConfig.DEFAULT_CATEGORY_NAME, :display_name => 'Tags'.t); end
  def self.ambiguous_tag_category; @@ambiguous_tag_category || @@ambiguous_tag_category = TagCategory.find_or_create_official_category(ArchiveConfig.AMBIGUOUS_CATEGORY_NAME, :display_name => 'Ambiguous'.t); end

  def self.initialize_tag_categories
    @@warning_tag_category = self.find_or_create_official_category(ArchiveConfig.WARNING_CATEGORY_NAME, :required => true)
    @@rating_tag_category = self.find_or_create_official_category(ArchiveConfig.RATING_CATEGORY_NAME, :required => true, :exclusive => true)
    @@fandom_tag_category = self.find_or_create_official_category(ArchiveConfig.FANDOM_CATEGORY_NAME, :required => true)
    @@category_tag_category = self.find_or_create_official_category(ArchiveConfig.CATEGORY_CATEGORY_NAME, :required => false, :exclusive => true)
    @@pairing_tag_category = self.find_or_create_official_category(ArchiveConfig.PAIRING_CATEGORY_NAME)
    @@character_tag_category = self.find_or_create_official_category(ArchiveConfig.CHARACTER_CATEGORY_NAME)
    @@default_tag_category = self.find_or_create_official_category(ArchiveConfig.DEFAULT_CATEGORY_NAME, :display_name => 'Tags'.t)
    @@ambiguous_tag_category = self.find_or_create_official_category(ArchiveConfig.AMBIGUOUS_CATEGORY_NAME, :display_name => 'Ambiguous'.t)

    @@official_tag_categories = self.official
  end

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

end
