class Tag < ActiveRecord::Base
  belongs_to :tag_category
  has_many :taggings, :as => :taggable, :dependent => :destroy
  include TaggingExtensions

  validates_length_of :name, :maximum => 42
  validates_format_of :name, 
                      :with => /\A[-a-zA-Z0-9 \/?.!''"";\|\]\[}{=~!@#\$%^&()_+]+\z/, 
                      :message => "tags can only be made up of letters, numbers, spaces and basic punctuation, but not commas and colons"
  validates_presence_of :tag_category_id
  
  def before_save
    self.name = name.strip.squeeze(" ")
  end
  
  def tagees(kind=['Tags', 'Works', 'Bookmarks'])
    kind.collect {|k| Tagging.tagees(:conditions => {:tag_id => self.id, :taggable_type => k.singularize}) }.flatten.compact
  end
  
  def valid
    return self if !banned
  end
  
  def visible
    return self if canonical
  end
  
  def <=>(another_tag)
    name <=> another_tag.name
  end

  def name
    self.canonical? ? super.titlecase : super
  end
end
