class TagCategory < ActiveRecord::Base
  has_many :tags
  
  validates_uniqueness_of :name
  
  before_destroy :remove_me_from_my_tags
  
  named_scope :ordered, :order => 'official, required DESC, exclusive DESC'
  named_scope :official, :conditions => 'official', :order => 'official, required DESC, exclusive DESC'
  named_scope :required, :conditions => :required

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
  
  # required ambiguous category, if it doesn't exist, create it.
  def self.ambiguous
    find_by_name('ambiguous') || TagCategory.create({ :name => 'ambiguous'.t, :display_name => 'Ambiguous'.t })
  end

  # required default category, if it doesn't exist, create it.
  def self.default
    find_by_name('default') || TagCategory.create({ :name => 'default'.t, :official => true, :display_name => 'Tags'.t })
  end


  def self.official_tags(category_name)
    category = find_by_name(category_name)
    return [] unless category
    category.tags.map(&:official).compact.sort
  end
  
  def display_name
    display_name? ? super : name
  end

  # force creation in an empty database
  self.ambiguous
  self.default
  
end
