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
  
  named_scope :valid, {:conditions => {:banned => false}}
  named_scope :canonical, {:conditions => {:canonical => true}}
  named_scope :by_category, lambda { |*args| {:conditions => ["tag_category_id IN (?)", args.flatten.collect(&:id)] }}  
  named_scope :by_popularity, {:order => 'taggings_count DESC'}
  named_scope :ordered_by_name, {:order => 'name ASC'}

  named_scope :with_names, lambda {|tagnames| 
    {
      :conditions => ["name IN (?)", tagnames]
    }
  }
  
  named_scope :from_relationship, lambda {|tag, relationship_kind|
    {
      :select => "DISTINCT tags.*",
      :joins => "INNER JOIN tag_relationships ON tags.id = tag_relationships.tag_id",
      :conditions => ['tag_relationships.tag_id = ? AND tag_relationships.tag_relationship_kind_id = ?', tag.id, relationship_kind.id]      
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

  @@default_warning_tag = nil
  @@no_warning_tag = nil

  @@default_rating_tag = nil
  @@explicit_rating_tag = nil
  @@mature_rating_tag = nil
  @@teen_rating_tag = nil
  @@general_rating_tag = nil

  @@het_category_tag = nil
  @@slash_category_tag = nil
  @@femslash_category_tag = nil
  @@gen_category_tag = nil
  @@multi_category_tag = nil
  @@other_category_tag = nil

  def self.default_warning_tag; @@default_warning_tag || @@default_warning_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.DEFAULT_WARNING_TAG_NAME, TagCategory.warning_tag_category); end
  def self.no_warning_tag; @@no_warning_tag || @@no_warning_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.NO_WARNING_TAG_NAME, TagCategory.warning_tag_category); end

  def self.default_rating_tag; @@default_rating_tag || @@default_rating_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.DEFAULT_RATING_TAG_NAME, TagCategory.rating_tag_category); end
  def self.explicit_rating_tag; @@explicit_rating_tag || @@explicit_rating_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.EXPLICIT_RATING_TAG_NAME, TagCategory.rating_tag_category); end
  def self.mature_rating_tag; @@mature_rating_tag || @@mature_rating_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.MATURE_RATING_TAG_NAME, TagCategory.rating_tag_category); end
  def self.teen_rating_tag; @@teen_rating_tag || @@teen_rating_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.TEEN_RATING_TAG_NAME, TagCategory.rating_tag_category); end
  def self.general_rating_tag; @@general_rating_tag || @@general_rating_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.GENERAL_RATING_TAG_NAME, TagCategory.rating_tag_category); end

  def self.het_category_tag; @@het_category_tag || @@het_category_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.HET_CATEGORY_TAG_NAME, TagCategory.category_tag_category); end
  def self.slash_category_tag; @@slash_category_tag || @@slash_category_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.SLASH_CATEGORY_TAG_NAME, TagCategory.category_tag_category); end
  def self.femslash_category_tag; @@femslash_category_tag || @@femslash_category_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.FEMSLASH_CATEGORY_TAG_NAME, TagCategory.category_tag_category); end
  def self.gen_category_tag; @@gen_category_tag || @@gen_category_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.GEN_CATEGORY_TAG_NAME, TagCategory.category_tag_category); end
  def self.multi_category_tag; @@multi_category_tag || @@multi_category_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.MULTI_CATEGORY_TAG_NAME, TagCategory.category_tag_category); end
  def self.other_category_tag; @@other_category_tag || @@other_category_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.OTHER_CATEGORY_TAG_NAME, TagCategory.category_tag_category); end

  def self.initialize_tags
    @@default_warning_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.DEFAULT_WARNING_TAG_NAME, TagCategory.warning_tag_category)
    @@no_warning_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.NO_WARNING_TAG_NAME, TagCategory.warning_tag_category)

    @@default_rating_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.DEFAULT_RATING_TAG_NAME, TagCategory.rating_tag_category)
    @@explicit_rating_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.EXPLICIT_RATING_TAG_NAME, TagCategory.rating_tag_category)
    @@mature_rating_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.MATURE_RATING_TAG_NAME, TagCategory.rating_tag_category)
    @@teen_rating_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.TEEN_RATING_TAG_NAME, TagCategory.rating_tag_category)
    @@general_rating_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.GENERAL_RATING_TAG_NAME, TagCategory.rating_tag_category)

    @@het_category_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.HET_CATEGORY_TAG_NAME, TagCategory.category_tag_category)
    @@slash_category_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.SLASH_CATEGORY_TAG_NAME, TagCategory.category_tag_category)
    @@femslash_category_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.FEMSLASH_CATEGORY_TAG_NAME, TagCategory.category_tag_category)
    @@gen_category_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.GEN_CATEGORY_TAG_NAME, TagCategory.category_tag_category)
    @@multi_category_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.MULTI_CATEGORY_TAG_NAME, TagCategory.category_tag_category)
    @@other_category_tag = Tag.find_or_create_canonical_tag(ArchiveConfig.OTHER_CATEGORY_TAG_NAME, TagCategory.category_tag_category)
  end
  
  def is_in_relationship_with?(other_tag, relationship_kind)
    return (Tag.from_relationship(self, relationship_kind).count > 0)
  end

  def self.find_or_create_canonical_tag(tagname, category)
    find_by_name(tagname) || self.create({:name => tagname, :tag_category_id => category.id, :canonical => true})
  end

  # the default warning(s) put on a new work
  def Tag.default_warning
   [self.default_warning_tag]
  end
  #default rating
  def Tag.default_rating
    [self.default_rating_tag]
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
    tags = [self] + self.synonyms
    Work.visible.with_any_tags(tags).count
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
      condition_list = "(tags.banned = :false) AND (tag_relationships.tag_id = :id OR tag_relationships.related_tag_id = :id)"
      condition_hash = {:false => false, :id => self.id}   
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
