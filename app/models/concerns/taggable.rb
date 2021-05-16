module Taggable
  extend ActiveSupport::Concern

  included do
    attr_accessor :invalid_tags
    attr_accessor :preview_mode, :placeholder_tags

    has_many :taggings, as: :taggable, inverse_of: :taggable, dependent: :destroy
    has_many :tags, through: :taggings, source: :tagger, source_type: "Tag"

    Tag::VISIBLE.each do |type|
      has_many type.underscore.pluralize.to_sym,
               -> { where(tags: { type: type }) },
               through: :taggings,
               source: :tagger,
               source_type: "Tag",
               before_remove: :destroy_tagging
    end

    after_update :reset_placeholders
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

  # Returns a string of tag names of all types
  def tag_string
    tags.map(&:name).join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
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

  # Process a string of tags from any tag class. Unlike #parse_tags, it allows the creation of UnsortedTag instances.
  # Used in bookmarks and collections.
  def tag_string=(tag_string)
    # Make sure that we trigger the callback for our taggings.
    self.taggings.destroy_all

    tags = []

    # Replace unicode full-width commas
    tag_string.gsub!(/\uff0c|\u3001/, ",")
    tag_array = tag_string.split(ArchiveConfig.DELIMITER_FOR_INPUT)

    tag_array.each do |string|
      string.strip!
      next if string.blank?

      tags << (Tag.find_by_name(string) || UnsortedTag.create(name: string))
    end

    self.tags = tags.uniq
  end

  alias category_strings= category_string=
  alias archive_warning_strings= archive_warning_string=

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
      next if string.blank?

      tag = if Tag::USER_DEFINED.include?(klass.to_s)
              klass.find_or_create_by_name(string)
            else
              klass.find_by(name: string, canonical: true)
            end
      next unless tag.present? && tag.is_a?(klass)

      if tag.valid?
        tags << tag if tag.is_a?(klass)
      else
        self.invalid_tags << tag
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

  def destroy_tagging(tag)
    taggings.find_by(tagger: tag)&.destroy
  end
end
