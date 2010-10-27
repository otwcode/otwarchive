class TagSet < ActiveRecord::Base
  
  # a complete match is numerically represented with ALL
  ALL = -1
  
  TAG_TYPES = %w(fandom character relationship freeform category rating warning)
  TAG_TYPES_INITIALIZABLE = %w(fandom character relationship freeform)
  TAG_TYPES_RESTRICTED_TO_FANDOM = %w(character relationship)
  TAGS_AS_CHECKBOXES = %w(category rating warning)
  
  has_many :set_taggings, :dependent => :destroy
  has_many :tags, :through => :set_taggings

  has_one :prompt

  # how this works: we don't want to set the actual "tags" variable initially because that will
  # create SetTaggings even if the tags are not canonical or wrong. So we need to create a temporary
  # virtual attribute "tagnames" to use instead until after validation.
  attr_writer :tagnames
  def tagnames
    @tagnames || tags.select('tags.name').order('tags.name').collect(&:name).join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
  end
  def taglist
    @tagnames ? tagnames_to_list(@tagnames) : tags
  end
  
  # this code just sets up functions fandom_tagnames/fandom_tagnames=, character_tagnames... etc
  # that work like tagnames above, except on separate types. 
  # 
  # NOTE: you can't use both these individual
  # setters and tagnames in the same form -- ie, if you set tagnames and then you set fandom_tagnames, you
  # will wipe out the fandom tagnames set in tagnames.
  #
  TAG_TYPES.each do |type|
    attr_writer "#{type}_tagnames".to_sym

    attr_accessor "#{type}_init_less_than_average".to_sym 
    attr_accessor "#{type}_init_greater_than_average".to_sym
    attr_accessor "#{type}_init_factor".to_sym

    define_method("#{type}_tagnames") do
      self.instance_variable_get("@#{type}_tagnames") || (self.new_record? ? self.tags.select {|t| t.type == type.classify}.collect(&:name).join(ArchiveConfig.DELIMITER_FOR_OUTPUT) : 
                                                                             self.tags.with_type(type.classify).select('tags.name').order('tags.name').collect(&:name).join(ArchiveConfig.DELIMITER_FOR_OUTPUT))
    end
    
    define_method("#{type}_taglist") do
      self.instance_variable_get("@#{type}_tagnames") ? tagnames_to_list(self.instance_variable_get("@#{type}_tagnames"), "#{type}") : with_type(type)
    end
  end
  
  # If the user wants to initialize the tags, let them
  before_validation :init_tags
  def init_tags
    tags_to_set = []
    if self.fandom_init_less_than_average == "1" || self.fandom_init_greater_than_average == "1"
      tags_to_set += Fandom.with_popularity_relative_to_average(:factor => self.fandom_init_factor.to_i, :greater_than => self.fandom_init_greater_than_average == "1")
    end
    if self.character_init_less_than_average == "1" || self.character_init_greater_than_average == "1"
      tags_to_set += Character.with_popularity_relative_to_average(:factor => self.character_init_factor.to_i, :greater_than => self.character_init_greater_than_average == "1")
    end
    if self.relationship_init_less_than_average == "1" || self.relationship_init_greater_than_average == "1"
      tags_to_set += Relationship.with_popularity_relative_to_average(:factor => self.relationship_init_factor.to_i, :greater_than => self.relationship_init_greater_than_average == "1")
    end
    if self.freeform_init_less_than_average == "1" || self.freeform_init_greater_than_average == "1"
      tags_to_set += Freeform.with_popularity_relative_to_average(:factor => self.freeform_init_factor.to_i, :greater_than => self.freeform_init_greater_than_average == "1")
    end
    unless tags_to_set.empty?
      self.tags = tags_to_set
      @tag_set_initialized = true
    end
  end

  # this actually runs and saves the tags but only after validation
  after_save :assign_tags
  def assign_tags
    return if @initialized
    if @tagnames
      self.tags = tagnames_to_list(@tagnames)
    end
    
    TAG_TYPES.each do |type|
      if eval("@#{type}_tagnames")
        new_tags = eval("#{type}_taglist")
        old_tags = self.with_type(type.classify)
        tags_to_set = (self.tags - old_tags + new_tags).compact.uniq
        self.tags = tags_to_set
      end
    end
  end

  validate :all_tags_must_be_canonical  
  def all_tags_must_be_canonical
    uncanonical_tags = self.taglist.reject {|tag| tag.canonical}
    unless uncanonical_tags.empty?
      errors.add(:tagnames, t('tag_set.must_be_canonical', 
                :default => "^The following tags aren't canonical and can't be used: %{taglist}", 
                :taglist => uncanonical_tags.collect(&:name).join(", ") ))
    end
    
    TAG_TYPES.each do |type|
      uncanonical_tags = eval("#{type}_taglist").reject {|tag| tag.canonical}
      unless uncanonical_tags.empty?
        errors.add("#{type}_tagnames", t("tag_set.#{type}_must_be_canonical", 
                  :default => "^The following #{type} tags aren't canonical and can't be used: %{taglist}", 
                  :taglist => uncanonical_tags.collect(&:name).join(", ") ))
      end
    end
  end
  
  scope :matching, lambda {|tag_set_to_match|
    select("DISTINCT tag_sets.*").
    joins(:tags).
    group('tag_sets.id').
    where("tag_sets.id != ? AND tags.id in (?)", tag_set_to_match.id, tag_set_to_match.tags).
    order("count(tags.id) desc")
  }
  
  def +(other)
    TagSet.new(:tags => (self.tags + other.tags))
  end
  
  def -(other)
    TagSet.new(:tags => (self.tags - other.tags))
  end
  
  def has_tag?(tag)
    self.tags.include?(tag)
  end
  
  def with_type(type)
    return self.new_record? ? self.tags.select {|t| t.type == type.classify} : self.tags.with_type(type)
  end

  def tags_with_type(type)
    return with_type(type)
  end

  def empty?
    self.tags.empty?
  end
  
  def match_rank(another, type=nil)
    # if we don't have any tags of this type, anything matches us
    return ALL if tags.empty?
    return ALL if type && tags_with_type(type).empty?
    return ALL if is_subset_of?(another, type) 
    matching_tags(another, type).size
  end
  
  def exact_match?(another, type=nil)
    if type
      self.tags_with_type(type).to_a == another.tags_with_type(type).to_a
    else
      self.tags == another.tags
    end
  end
    
  def no_match?(another, type=nil)
    if type
      (self.tags_with_type(type).to_a & another.tags_with_type(type).to_a).empty? && !self.tags.empty?
    else
      (self.tags & another.tags).empty? && !self.tags.empty?
    end
  end
  
  def partial_match?(another, type=nil)
    if type
      !(self.tags_with_type(type).to_a & another.tags_with_type(type).to_a).empty?
    else
      !(self.tags & another.tags).empty?
    end
  end
  
  # checks to see if this is a subset of another tagset
  # note: we have to cast tags_with_type to an array because one of the tag sets may actually
  # be an activequery object 
  def is_subset_of?(another, type=nil)
    if type
      (self.tags_with_type(type).to_a & another.tags_with_type(type).to_a) == self.tags_with_type(type).to_a
    else
      (self.tags & another.tags) == self.tags
    end
  end
  
  # checks to see if this is a superset of another tagset
  # note: we have to cast tags_with_type to an array because one of the tag sets may actually
  # be an activequery object 
  def is_superset_of?(another, type=nil)
    if type
      (self.tags_with_type(type).to_a & another.tags_with_type(type).to_a) == another.tags_with_type(type).to_a
    else
      (self.tags & another.tags) == another.tags
    end
  end

  # returns matching tags
  def matching_tags(another, type=nil)
    if type
      self.tags_with_type(type).to_a & another.tags_with_type(type).to_a
    else
      self.tags & another.tags
    end
  end  
  
  ### protected 
  
  protected
    def tagnames_to_list(taglist, type=nil)
      taglist = (taglist.kind_of?(String) ? taglist.split(ArchiveConfig.DELIMITER_FOR_INPUT) : taglist)
      if type
        taglist.reject {|tagname| tagname.blank? }.map {|tagname| (type.classify.constantize).find_or_create_by_name(tagname.squish)}
      else
        taglist.reject {|tagname| tagname.blank? }.map {|tagname| Tag.find_by_name(tagname.squish) || Freeform.find_or_create_by_name(tagname.squish)}
      end
    end
  
end
