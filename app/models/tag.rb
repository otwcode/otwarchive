class Tag < ActiveRecord::Base
  belongs_to :tag_category
  has_many :taggings, :as => :taggable, :dependent => :destroy
  belongs_to :tagging, :dependent => :destroy
  include TaggingExtensions

  validates_length_of :name, :maximum => 42
  validates_format_of :name, 
                      :with => /\A[-a-zA-Z0-9 \/?.!''"";\|\]\[}{=~!@#\$%^&()_+]+\z/, 
                      :message => "tags can only be made up of letters, numbers, spaces and basic punctuation, but not commas and colons"
  validates_uniqueness_of :name
  
  def before_create
    self.name = name.strip.squeeze(" ")
  end
  
  def tagees(kind=['Tags', 'Works', 'Bookmarks'])
    kind.collect {|k| Tagging.tagees(:conditions => {:tag_id => self.id, :taggable_type => k.singularize}) }.flatten.compact
  end
  
  def valid
    return self if !banned
  end
  
  def official
    return self if canonical
  end
  
  # sort tags by name
  def <=>(another_tag)
    name <=> another_tag.name
  end
  
  def synonyms
    Tagging.find(:all, :conditions => {:taggable_id => self.id, :taggable_type => 'Tag', :tag_relationship_id => TagRelationship.synonym.id}).collect(&:tag) - [self]
  end
  
  def disambiguates
    Tagging.find(:all, :conditions => {:taggable_id => self.id, :taggable_type => 'Tag', :tag_relationship_id => TagRelationship.disambiguate.id}).collect(&:tag) - [self]
  end

  def name
    self.canonical? ? super.gsub(/\b([a-z])/) { $1.capitalize } : super
  end
  
end
