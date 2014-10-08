module Taggable

  def self.included(taggable)
    taggable.class_eval do
      attr_accessor :invalid_tags
      attr_accessor :preview_mode, :placeholder_tags
      after_update :reset_placeholders

      has_many :filter_taggings, :as => :filterable
      has_many :filters, :through => :filter_taggings
      has_many :direct_filter_taggings, :class_name => "FilterTagging", :as => :filterable, :conditions => "inherited = 0"
      has_many :direct_filters, :source => :filter, :through => :direct_filter_taggings

      has_many :taggings, :as => :taggable, :dependent => :destroy
      has_many :tags, :through => :taggings, :source => :tagger, :source_type => 'Tag'

      has_many :ratings,
        :through => :taggings,
        :source => :tagger,
        :source_type => 'Tag',
        :before_remove => :remove_filter_tagging,
        :conditions => "tags.type = 'Rating'"
      has_many :categories,
        :through => :taggings,
        :source => :tagger,
        :source_type => 'Tag',
        :before_remove => :remove_filter_tagging,
        :conditions => "tags.type = 'Category'"
      has_many :warnings,
        :through => :taggings,
        :source => :tagger,
        :source_type => 'Tag',
        :before_remove => :remove_filter_tagging,
        :conditions => "tags.type = 'Warning'"
      has_many :fandoms,
        :through => :taggings,
        :source => :tagger,
        :source_type => 'Tag',
        :before_remove => :remove_filter_tagging,
        :conditions => "tags.type = 'Fandom'"
      has_many :relationships,
        :through => :taggings,
        :source => :tagger,
        :source_type => 'Tag',
        :before_remove => :remove_filter_tagging,
        :conditions => "tags.type = 'Relationship'"
      has_many :characters,
        :through => :taggings,
        :source => :tagger,
        :source_type => 'Tag',
        :before_remove => :remove_filter_tagging,
        :conditions => "tags.type = 'Character'"
      has_many :freeforms,
        :through => :taggings,
        :source => :tagger,
        :source_type => 'Tag',
        :before_remove => :remove_filter_tagging,
        :conditions => "tags.type = 'Freeform'"
    end
  end

  # string methods
  # (didn't use define_method, despite the redundancy, because it doesn't cache in development)
  def rating_string
    tag_category_string(:ratings)
  end
  def category_string
    tag_category_string(:categories)
  end
  def category_strings
    tag_category_string(:categories, :return_array => true)
  end
  def warning_string
    tag_category_string(:warnings)
  end
  def warning_strings
    tag_category_string(:warnings, :return_array => true)
  end
  def fandom_string
    tag_category_string(:fandoms)
  end
  def relationship_string
    tag_category_string(:relationships)
  end
  def character_string
    tag_category_string(:characters)
  end
  def freeform_string
    tag_category_string(:freeforms)
  end

  # _string= methods
  # always use string= methods to set tags
  # << and = don't trigger callbacks to update common_tags
  # or call after_destroy on taggings
  # see rails bug http://dev.rubyonrails.org/ticket/7743
  def rating_string=(tag_string)
    parse_tags(Rating, tag_string)
  end
  def category_string=(tag_string)
    parse_tags(Category, tag_string)
  end
  def warning_string=(tag_string)
    parse_tags(Warning, tag_string)
  end
  def warning_strings=(array)
    parse_tags(Warning, array)
  end
  def fandom_string=(tag_string)
    parse_tags(Fandom, tag_string)
  end
  def relationship_string=(tag_string)
    parse_tags(Relationship, tag_string)
  end
  def character_string=(tag_string)
    parse_tags(Character, tag_string)
  end
  def freeform_string=(tag_string)
    parse_tags(Freeform, tag_string)
  end

  # a work can only have one rating, so using first will work
  # should always have a rating, if it doesn't err conservatively
  def adult?
    self.ratings.blank? || self.ratings.first.adult?
  end

  # Make sure we don't have any phantom values hanging around
  def reset_placeholders
    self.preview_mode = false
    self.placeholder_tags = {}
  end

  def validate_tags
    errors.add(:base, "Work must have required tags.") unless self.has_required_tags?
    self.has_required_tags?
  end

  # Add an error message if the user tried to add invalid tags to the work
  def check_for_invalid_tags
    unless self.invalid_tags.blank?
      errors.add(:base, "The following tags are invalid: " + self.invalid_tags.collect(&:name).join(', ') + ". Please make sure that your tags are less than #{ArchiveConfig.TAG_MAX} characters long and do not contain any invalid characters.")
      self.invalid_tags.each do |tag|
        tag.errors.to_a.each do |error|
          errors.add(:base, error)
        end
      end
    end
    self.invalid_tags.blank?
  end

  def cast_tags
    # we combine relationship and character tags up to the limit
    characters = self.characters.by_name || []
    relationships = self.relationships.by_name || []
    return [] if relationships.empty? && characters.empty?
    canonical_relationships = Relationship.canonical.by_name.find(:all, :conditions => {:id => relationships.collect(&:merger_id).compact.uniq})
    all_relationships = (relationships + canonical_relationships).flatten.uniq.compact

    #relationship_characters = all_relationships.collect{|p| p.all_characters}.flatten.uniq.compact
    relationship_characters = Character.by_relationships(all_relationships)
    relationship_characters = (relationship_characters + relationship_characters.collect(&:mergers).flatten).compact.uniq

    line_limited_tags(relationships + characters - relationship_characters)
  end

  def relationship_tags
    taglist = self.tags.select {|t| t.is_a?(Relationship)}
    line_limited_tags(taglist)
  end

  def character_tags
    taglist = self.tags.select {|t| t.is_a?(Character)}
    line_limited_tags(taglist)
  end

  def freeform_tags
    taglist = self.tags.select {|t| t.is_a?(Freeform)}
    line_limited_tags(taglist)
  end

  def warning_tags
    taglist = self.tags.select {|t| t.is_a?(Warning)}
    line_limited_tags(taglist)
  end

  def line_limited_tags(taglist)
    taglist = taglist[0..(ArchiveConfig.TAGS_PER_LINE-1)] if taglist.size > ArchiveConfig.TAGS_PER_LINE
    taglist
  end

  def fandom_tags
    self.tags.select {|t| t.is_a?(Fandom)}
  end

  # for testing
  def add_default_tags
    self.fandom_string = "Test Fandom"
    self.rating_string = ArchiveConfig.RATING_TEEN_TAG_NAME
    self.warning_strings = [ArchiveConfig.WARNING_NONE_TAG_NAME]
    self.save
  end

  private

  # Returns a string (or array) of tag names
  def tag_category_string(category, options={})
    return "" unless self.respond_to?(category)
    if !self.placeholder_tags.blank?
      tag_array = self.placeholder_tags[category] || []
    else
      tag_array = self.send(category)
    end
    tag_names = tag_array.map {|tag| tag.name}
    if options[:return_array]
      tag_names
    else
      tag_names.join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
    end
  end

  # Process a string or array of tags from any tag class
  def parse_tags(klass, incoming_tags)
    tags = []
    self.invalid_tags ||= []
    klass_symbol = klass.to_s.downcase.pluralize.to_sym
    if incoming_tags.is_a?(String)
      # Replace unicode full-width commas
      incoming_tags.gsub!(/\uff0c|\u3001/, ',')
      tag_array = incoming_tags.split(ArchiveConfig.DELIMITER_FOR_INPUT)
    else
      tag_array = incoming_tags
    end
    tag_array.each do |string|
      string.strip!
      unless string.blank?
        tag = klass.find_or_create_by_name(string)
        if tag.valid?
          tags << tag if tag.is_a?(klass)
        else
          self.invalid_tags << tag
        end
      end
    end
    if self.preview_mode
      self.placeholder_tags ||= {}
      self.placeholder_tags[klass_symbol] = tags.uniq
    else
      # we have to destroy the taggings directly in order to trigger the callbacks
      remove = self.send(klass_symbol) - tags
      remove.each do |tag|
        tagging = Tagging.find_by_tag(self, tag)
        tagging.destroy if tagging
      end
      self.send(klass_symbol.to_s + '=', tags.uniq)
    end
  end

  ################
  # SEARCH
  ################

  public

  # Simple name to make it easier for people to use in full-text search
  def tag
    (tags + filters).uniq.map{ |t| t.name }
  end

  # Index all the filters for pulling works
  def filter_ids
    filters.value_of :id
  end

  # Index only direct filters (non meta-tags) for facets
  def filters_for_facets
    @filters_for_facets ||= filters.where("filter_taggings.inherited = 0")
  end
  def rating_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Rating' }.map{ |t| t.id }
  end
  def warning_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Warning' }.map{ |t| t.id }
  end
  def category_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Category' }.map{ |t| t.id }
  end
  def fandom_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Fandom' }.map{ |t| t.id }
  end
  def character_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Character' }.map{ |t| t.id }
  end
  def relationship_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Relationship' }.map{ |t| t.id }
  end
  def freeform_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Freeform' }.map{ |t| t.id }
  end

end