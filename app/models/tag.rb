class Tag < ActiveRecord::Base
  belongs_to :tag_category
  has_many :tag_relationships, :dependent => :destroy
  has_many :related_relationships, :foreign_key => 'related_tag_id', :class_name => 'TagRelationship', :dependent => :destroy  
  has_many :tags, :through => :related_relationships
  has_many :related_tags, :through => :tag_relationships

  has_many :taggings, :dependent => :destroy
  has_many :works, :through => :taggings, :source => :taggable, :source_type => 'Work'
  has_many :bookmarks, :through => :taggings, :source => :taggable, :source_type => 'Bookmark'
  include TaggingExtensions

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => ArchiveConfig.TAG_MAX
  validates_format_of :name, 
                      :with => /\A[-a-zA-Z0-9 \/?.!''"";\|\]\[}{=~!@#\$%^&()_+]+\z/, 
                      :message => "tags can only be made up of letters, numbers, spaces and basic punctuation, but not commas, colons, asterisks or angle brackets".t
  
  named_scope :valid, {:conditions => 'banned = 0 OR banned IS NULL'}
  named_scope :by_category, lambda { |*args| {:conditions => "tag_category_id IN (#{args.collect(&:id).join(",")})"}}  
  
  def before_validation
    self.name = name.strip.squeeze(" ") if self.name
  end
  
  def after_update
    if self.adult_changed?
      self.works.each do |work|
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
        siblings.map(&:valid).compact
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
  
  # Return all tags directly related to this one
  def siblings(kind=nil)
    if kind.nil?
      conditions = ['tag_relationships.tag_id = ? OR tag_relationships.related_tag_id = ?', self.id, self.id]
    else
      conditions = ['tag_relationships.tag_relationship_kind_id = ? AND (tag_relationships.tag_id = ? OR tag_relationships.related_tag_id = ?)', kind.id, self.id, self.id]
    end
    Tag.find(:all, :include => :tag_relationships, :conditions => conditions) 
  end
  
  # create dynamic methods based on the tag relationships
  begin
    TagRelationshipKind.all.each do |kind|
      define_method(kind.name){
        kind.reciprocal? ? siblings(kind) : related_tags.find(:all, :conditions => ['tag_relationships.tag_relationship_kind_id = ?', kind.id])
      }
    end 
  rescue
    define_method('disambiguation'){ siblings(TagRelationshipKind.disambiguation) }
  end

  def name
    self.canonical? ? super.gsub(/\b([a-z])/) { $1.capitalize } : super
  end
  
end
