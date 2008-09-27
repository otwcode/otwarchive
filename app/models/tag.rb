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
  validates_uniqueness_of :name, :scope => [:tag_category_id]
  validates_length_of :name, :maximum => ArchiveConfig.TAG_MAX, 
                             :message => "is too long -- try using less than #{ArchiveConfig.TAG_MAX} characters or using commas to separate your tags.".t
  validates_format_of :name, 
                      :with => /\A[-a-zA-Z0-9 \/?.!''"":;\|\]\[}{=~!@#\$%^&()_+]+\z/, 
                      :message => "can only be made up of letters, numbers, spaces and basic punctuation, but not commas, asterisks or angle brackets.".t
  
  named_scope :valid, {:conditions => 'banned = 0 OR banned IS NULL'}
  named_scope :canonical, {:conditions => {:canonical => true}}
  named_scope :by_category, lambda { |*args| {:conditions => ["tag_category_id IN (?)", args.flatten.collect(&:id).join(",")] }}  
  named_scope :by_popularity, {:order => 'taggings_count DESC'}

  named_scope :with_names, lambda {|tagnames| 
    {
      :conditions => ["name IN (?)", tagnames]
    }
  }
  
  TAGGING_JOIN = "INNER JOIN taggings on tags.id = taggings.tag_id
                  INNER JOIN works ON (works.id = taggings.taggable_id AND taggings.taggable_type = 'Work')"

  named_scope :on_works, lambda {|tagged_works|
    {
      :select => "DISTINCT tags.*",
      :joins => TAGGING_JOIN,
      :conditions => ['works.id in (?)', tagged_works.collect(&:id)]
    }
  }


  # the default warning(s) put on a new work
  def Tag.default_warning
   ["Chooses Not To Warn"]
  end
  #default rating
  def Tag.default_rating
    ["Not Rated"]
  end
  
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
  def visible(kind, current_user=User.current_user)
    case kind
      when 'Works', 'Bookmarks'
        Tagging.tagees(:conditions => {:tag_id => self.id, :taggable_type => kind.singularize}).select {|t| t if t.visible(current_user)}
      when 'Tags'
        siblings
    end
  end
  
  # Gets the work count for this tag and its synonyms
  def visible_work_count(current_user=:false)
    ids = ([self] + self.synonyms).compact.collect(&:id).join(',')
    conditions = "taggings.tag_id IN (#{ids})"
    if current_user.is_a?(User)
      pseud_ids = current_user.pseuds.collect(&:id).join(',')
      conditions += " AND (works.hidden_by_admin = 0 OR works.hidden_by_admin IS NULL OR pseuds.id IN (#{pseud_ids}))"
    elsif current_user != "admin"
      conditions += " AND restricted = 0"
    end
    Work.posted.count(:all, :include => [:pseuds, {:taggings => :tag}], :conditions => conditions)
  end
  
  def valid
    return self if !banned
  end
  
  def official
    return self if canonical
  end
  
  # sort tags by name
  def <=>(another_tag)
    name.downcase <=> another_tag.name.downcase
  end
  
  # Return all valid tags directly related to this one
  # options = :kind (TagRelationshipKind), :category (TagCategory), :distance (TagRelationshipKind distance)
  def siblings(options = {})
    if options.blank?
      (self.tags + self.related_tags).uniq
    else  
      condition_list = "(tags.banned = 0 OR tags.banned IS NULL) AND (tag_relationships.tag_id = :id OR tag_relationships.related_tag_id = :id)"
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
      trs = TagRelationship.find(:all, :include => [:tag_relationship_kind, {:tag => :tag_category}, {:related_tag => :tag_category}], :conditions => [condition_list, condition_hash])      
      siblings = (trs.collect{|tr| [tr.tag, tr.related_tag]}).flatten.uniq - [self]
    end
  end
  
  def disambiguation
    siblings(:kind => TagRelationshipKind.disambiguation)
  end
  
  def synonyms
    siblings(:distance => 0) - self.disambiguation
  end
  
  def canonical_synonym
    self.synonyms.select {|tag| tag.canonical?}.first
  end
  
end
