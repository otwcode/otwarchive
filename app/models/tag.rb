class Tag < ActiveRecord::Base
  belongs_to :tag_category
  has_many :taggings, :dependent => :destroy
  has_many :works, :through => :taggings, :source => :taggable, :source_type => 'Work'
  has_many :bookmarks, :through => :taggings, :source => :taggable, :source_type => 'Bookmark'
  include TaggingExtensions

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => ArchiveConfig.TAG_MAX
  validates_format_of :name, 
                      :with => /\A[-a-zA-Z0-9 \/?.!''"";\|\]\[}{=~!@#\$%^&()_+]+\z/, 
                      :message => "tags can only be made up of letters, numbers, spaces and basic punctuation, but not commas, colons, asterisks or angle brackets"
  
  def before_validation
    self.name = name.strip.squeeze(" ") if self.name
  end
  
  def after_update
    if self.adult_changed?
      Tagging.tagees(:conditions => {:tag_id => self.id, :taggable_type => 'Work'}).each do |work|
        adult = false
        work.tags.each do |tag|
          adult = true if tag.adult
        end
        work.update_attribute('adult', adult)
      end
    end
    return true
  end
  
  # kind is one of 'Tags', 'Works', 'Bookmarks'
  # this function returns an array of visible 'kind's that have been tagged with the given tag.
  def visible(kind, current_user=:false)
    case kind
      when 'Works', 'Bookmarks'
        Tagging.tagees(:conditions => {:tag_id => self.id, :taggable_type => kind.singularize}).select {|t| t if t.visible(current_user)}
      when 'Tags'
        Tagging.tagees(:conditions => {:tag_id => self.id, :taggable_type => kind.singularize}).map(&:valid).compact
    end
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
