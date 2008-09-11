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
                      :with => /\A[-a-zA-Z0-9 \/?.!''"":;\|\]\[}{=~!@#\$%^&()_+]+\z/, 
                      :message => "tags can only be made up of letters, numbers, spaces and basic punctuation, but not commas, asterisks or angle brackets".t
  
  named_scope :valid, {:conditions => 'banned = 0 OR banned IS NULL'}
  named_scope :by_category, lambda { |*args| {:conditions => "tag_category_id IN (#{args.collect(&:id).join(",")})"}}  
  named_scope :by_popularity, {:order => 'taggings_count DESC'}
  
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
        siblings
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
  
  # Return all valid tags directly related to this one
  # options = :kind (TagRelationshipKind), :category (TagCategory), :distance (TagRelationshipKind distance)
  def siblings(options = {})
    if options.blank?
      (self.tags + self.related_tags).uniq
    else  
      condition_list = "tags.banned != 1"
      condition_hash = {:id => self.id}   
      if options[:kind].is_a?(TagRelationshipKind)
        condition_list += " AND tag_relationships.tag_relationship_kind_id = :kind_id"
        condition_hash[:kind_id] = options[:kind].id
      end
      unless options[:distance].blank?
        condition_list += " AND tag_relationship_kinds.distance = :distance"
        condition_hash[:distance] = options[:distance].to_i      
      end
      if options[:category].is_a?(TagCategory)
        condition_list += " AND tag_categories.id = :category_id"
        condition_hash[:category_id] = options[:category].id
      end      
      siblings = self.tags.find(:all, :include => [:tag_category, {:tag_relationships => :tag_relationship_kind}], :conditions => [condition_list, condition_hash])
      siblings += self.related_tags.find(:all, :include => [:tag_category, {:related_relationships => :tag_relationship_kind}], :conditions => [condition_list, condition_hash])
      siblings.uniq
    end
  end
  
  def disambiguation
    siblings(:kind => TagRelationshipKind.disambiguation)
  end
  
  def synonyms
    siblings(:distance => 0) - self.disambiguation
  end

  def name
    self.canonical? ? super.gsub(/\b([a-z])/) { $1.capitalize } : super
  end
  
end
