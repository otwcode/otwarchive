class TagSet < ActiveRecord::Base
  
  # a complete match is numerically represented with ALL
  ALL = -1
  
  TAG_TYPES = %w(fandom character relationship freeform category rating warning)
  TAG_TYPES_INITIALIZABLE = %w(fandom character relationship freeform)
  TAG_TYPES_RESTRICTED_TO_FANDOM = %w(character relationship)
  TAGS_AS_CHECKBOXES = %w(category rating warning)
  
  has_many :set_taggings, :dependent => :destroy
  has_many :tags, :through => :set_taggings
  
  has_one :owned_tag_set

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
  
  attr_writer :tagnames_to_remove
  def tagnames_to_remove
    @tagnames_to_remove || ""
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

    define_method("#{type}_tagnames") do
      self.instance_variable_get("@#{type}_tagnames") || (self.new_record? ? self.tags.select {|t| t.type == type.classify}.collect(&:name).join(ArchiveConfig.DELIMITER_FOR_OUTPUT) : 
                                                                             self.tags.with_type(type.classify).select('tags.name').order('tags.name').collect(&:name).join(ArchiveConfig.DELIMITER_FOR_OUTPUT))
    end
    
    define_method("#{type}_taglist") do
      self.instance_variable_get("@#{type}_tagnames") ? tagnames_to_list(self.instance_variable_get("@#{type}_tagnames"), "#{type}") : with_type(type)
    end
    
    # _to_add/remove only rather than reset the entire list (much faster in large tagsets!)
    attr_writer "#{type}_tagnames_to_add".to_sym
    define_method("#{type}_tagnames_to_add") do 
      self.instance_variable_get("@#{type}_tagnames_to_add") || ""
    end

    attr_writer "#{type}_tags_to_remove".to_sym
    define_method("#{type}_tags_to_remove") do 
      self.instance_variable_get("@#{type}_tags_to_remove") || ""
    end

  end
  
  # this actually runs and saves the tags and updates the autocomplete
  # NOTE: if more than one is set, the precedence is as follows:
  # tagnames=
  # tagnames_to_add/_remove
  # [type]_tagnames
  # [type]_tagnames_to_add/_remove
  after_save :assign_tags
  def assign_tags
    tags_to_add = []
    tags_to_remove = []

    TAG_TYPES.each do |type|
      if self.instance_variable_get("@#{type}_tagnames")
        # explicitly set the list of type_tagnames
        new_tags = self.send("#{type}_taglist")
        old_tags = self.with_type(type.classify)
        tags_to_add += (new_tags - old_tags)
        tags_to_remove += (old_tags - new_tags)
      else
        #
        if !self.instance_variable_get("@#{type}_tagnames_to_add").blank?
          tags_to_add += tagnames_to_list(self.instance_variable_get("@#{type}_tagnames_to_add"), type)
        end
        if !self.instance_variable_get("@#{type}_tags_to_remove").blank?
          tagclass = type.classify.constantize
          tags_to_remove += (self.instance_variable_get("@#{type}_tags_to_remove").map {|tag_id| tag_id.blank? ? nil : tagclass.find(tag_id)}.compact)
        end
      end
    end

    # These override the type-specific 
    if !@tagnames_to_add.blank?
      tags_to_add = tagnames_to_list(@tagnames_to_add)
    end
    if !@tagnames_to_remove.blank?
      tags_to_remove = @tagnames_to_remove.split(ArchiveConfig.DELIMITER_FOR_INPUT).map {|tname| Tag.find_by_name(tname.squish)}.compact
    end

    # And this overrides the add/remove-specific
    if @tagnames
      new_tags = tagnames_to_list(@tagnames)
      tags_to_add = new_tags - self.tags
      tags_to_remove = (self.tags - new_tags)
    end
    
    # actually remove and add the tags, and update autocomplete
    self.tags -= tags_to_remove
    remove_tags_from_autocomplete(tags_to_remove)

    self.tags += tags_to_add
    add_tags_to_autocomplete(tags_to_add)
  end
  
  scope :matching, lambda {|tag_set_to_match|
    select("DISTINCT tag_sets.*").
    joins(:tags).
    group('tag_sets.id').
    where("tag_sets.id != ? AND tags.id in (?)", tag_set_to_match.id, tag_set_to_match.tags).
    order("count(tags.id) desc")
  }


  ### Various utility methods
  
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
  
  # returns the topmost tag type we have in this set
  def topmost_tag_type
    topmost_type = ""
    TagSet::TAG_TYPES.each do |tag_type| 
      if self.tags.with_type(tag_type).exists? 
        topmost_type = tag_type
        break
      end
    end
    topmost_type
  end
  
  
  ### Matching
  
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
        if Tag::USER_DEFINED.include?(type.classify)
          # allow users to create these
          taglist.reject {|tagname| tagname.blank? }.map {|tagname| (type.classify.constantize).find_or_create_by_name(tagname.squish)}
        else
          taglist.reject {|tagname| tagname.blank? }.map {|tagname| (type.classify.constantize).find_by_name(tagname.squish)}.compact
        end
      else
        taglist.reject {|tagname| tagname.blank? }.map {|tagname| Tag.find_by_name(tagname.squish) || Freeform.find_or_create_by_name(tagname.squish)}
      end
    end


  ### autocomplete
  public

  # set up autocomplete and override some methods
  include AutocompleteSource
  
  def autocomplete_prefixes
    prefixes = [ ]
    prefixes
  end
  
  def add_to_autocomplete(score = nil)
    add_tags_to_autocomplete(self.tags)
  end

  def remove_from_autocomplete
    $redis.del("autocomplete_tagset_#{self.id}")
  end
  
  def add_tags_to_autocomplete(tags_to_add)
    tags_to_add.each do |tag| 
      value = tag.autocomplete_value
      $redis.zadd("autocomplete_tagset_all_#{self.id}", 0, value)
      $redis.zadd("autocomplete_tagset_#{tag.type.downcase}_#{self.id}", 0, value)
    end
  end
  
  def remove_tags_from_autocomplete(tags_to_remove)
    tags_to_remove.each do |tag| 
      value = tag.autocomplete_value
      $redis.zremove("autocomplete_tagset_all_#{self.id}", value)
      $redis.zremove("autocomplete_tagset_#{tag.type.downcase}_#{self.id}", value)
    end
  end
    
  # returns tags that are in ANY or ALL of the specified tag sets
  def self.autocomplete_lookup(options={})
    options.reverse_merge!({:term => "", :tag_type => "all", :tag_set => "", :in_any => true})
    tag_type = options[:tag_type]
    search_param = options[:term]
    tag_sets = TagSet.get_search_terms(options[:tag_set])

    combo_key = "autocomplete_tagset_combo_#{tag_sets.join('_')}"

    # get the intersection of the wrangled fandom and the associations from the various tag sets
    keys_to_lookup = tag_sets.map {|set| "autocomplete_tagset_#{tag_type}_#{set}"}.flatten
    
    if options[:in_any]
      # get the union since we want tags in ANY of these sets
      $redis.zunionstore(combo_key, keys_to_lookup, :aggregate => :max)
    else
      # take the intersection of ALL of these sets
      $redis.zinterstore(combo_key, keys_to_lookup, :aggregate => :max)
    end
    results = $redis.zrange(combo_key, 0, -1)
    # expire fast
    $redis.expire combo_key, 1
    
    unless search_param.blank?
      search_regex = Tag.get_search_regex(search_param)
      return results.select {|tag| tag.match(search_regex)}
    else
      return results
    end
  end
  
end
