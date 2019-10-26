module Taggable

  def self.included(taggable)
    taggable.class_eval do
      attr_accessor :invalid_tags
      attr_accessor :preview_mode, :placeholder_tags

      has_many :filter_taggings, as: :filterable
      has_many :filters, through: :filter_taggings
      has_many :direct_filter_taggings, -> { where(inherited: 0) }, class_name: "FilterTagging", as: :filterable
      has_many :direct_filters, source: :filter, through: :direct_filter_taggings

      has_many :taggings, as: :taggable, dependent: :destroy
      has_many :tags, through: :taggings, source: :tagger, source_type: 'Tag'

      has_many :ratings,
        -> { where("tags.type = 'Rating'") },
        through: :taggings,
        source: :tagger,
        source_type: 'Tag',
        before_remove: :remove_filter_tagging
      has_many :categories,
        -> { where("tags.type = 'Category'") },
        through: :taggings,
        source: :tagger,
        source_type: 'Tag',
        before_remove: :remove_filter_tagging
      has_many :archive_warnings,
        -> { where("tags.type = 'ArchiveWarning'") },
        through: :taggings,
        source: :tagger,
        source_type: 'Tag',
        before_remove: :remove_filter_tagging
      has_many :fandoms,
        -> { where("tags.type = 'Fandom'") },
        through: :taggings,
        source: :tagger,
        source_type: 'Tag',
        before_remove: :remove_filter_tagging
      has_many :relationships,
        -> { where("tags.type = 'Relationship'") },
        through: :taggings,
        source: :tagger,
        source_type: 'Tag',
        before_remove: :remove_filter_tagging
      has_many :characters,
        -> { where("tags.type = 'Character'") },
        through: :taggings,
        source: :tagger,
        source_type: 'Tag',
        before_remove: :remove_filter_tagging
      has_many :freeforms,
        -> { where("tags.type = 'Freeform'") },
        through: :taggings,
        source: :tagger,
        source_type: 'Tag',
        before_remove: :remove_filter_tagging

      after_update :reset_placeholders
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
    tag_category_string(:categories, return_array: true)
  end
  def archive_warning_string
    tag_category_string(:archive_warnings)
  end
  def archive_warning_strings
    tag_category_string(:archive_warnings, return_array: true)
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
  def archive_warning_string=(tag_string)
    parse_tags(ArchiveWarning, tag_string)
  end
  def archive_warning_strings=(array)
    parse_tags(ArchiveWarning, array)
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
    unless self.has_required_tags?
      errors.add(:base, "Work must have required tags.") unless self.has_required_tags?
      throw :abort
    end
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
    klass_symbol = klass.to_s.underscore.pluralize.to_sym
    if incoming_tags.is_a?(String)
      # Replace unicode full-width commas
      tag_array = incoming_tags.gsub(/\uff0c|\u3001/, ',').split(ArchiveConfig.DELIMITER_FOR_INPUT)
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
    (tags.pluck(:id) + filters.pluck(:id)).uniq
  end

  # Index only direct filters (non meta-tags) for facets
  def filters_for_facets
    @filters_for_facets ||= filters.where("filter_taggings.inherited = 0")
  end
  def rating_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Rating' }.map{ |t| t.id }
  end
  def archive_warning_ids
    filters_for_facets.select{ |t| t.type.to_s == 'ArchiveWarning' }.map{ |t| t.id }
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
