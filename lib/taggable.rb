module Taggable
  
  def self.included(taggable)
    taggable.class_eval do      
      attr_accessor :invalid_tags
      attr_accessor :preview_mode, :placeholder_tags  
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
  def pairing_string
    tag_category_string(:pairings)
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
  def pairing_string=(tag_string)
    parse_tags(Pairing, tag_string)
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
    errors.add_to_base("Work must have required tags.") unless self.has_required_tags?
    self.has_required_tags?
  end
  
  # Add an error message if the user tried to add invalid tags to the work
  def check_for_invalid_tags
    unless self.invalid_tags.blank?
      errors.add_to_base("The following tags are invalid: " + self.invalid_tags.collect(&:name).join(', ') + ". Please make sure that your tags are less than #{ArchiveConfig.TAG_MAX} characters long and do not contain any invalid characters.")
      self.invalid_tags.each do |tag|
        tag.errors.each_full do |error|
          errors.add_to_base(error)
        end
      end
    end
    self.invalid_tags.blank?  
  end

  def cast_tags
    # we combine pairing and character tags up to the limit
    characters = self.characters.by_name || []
    pairings = self.pairings.by_name || []
    return [] if pairings.empty? && characters.empty?
    canonical_pairings = Pairing.canonical.find(:all, :conditions => {:id => pairings.collect(&:merger_id).compact.uniq})
    all_pairings = (pairings + canonical_pairings).flatten.uniq.compact

    #pairing_characters = all_pairings.collect{|p| p.all_characters}.flatten.uniq.compact
    pairing_characters = Character.by_pairings(all_pairings)
    pairing_characters = (pairing_characters + pairing_characters.collect(&:mergers).flatten).compact.uniq

    line_limited_tags(pairings + characters - pairing_characters)
  end
  
  def pairing_tags
    line_limited_tags(self.pairings.by_name || [])
  end
  
  def character_tags
    line_limited_tags(self.characters.by_name || [])
  end

  def freeform_tags
    line_limited_tags(self.freeforms.by_name || [])
  end

  def warning_tags
    line_limited_tags(self.warnings.by_name || [])
  end
  
  def line_limited_tags(taglist)
    taglist = taglist[0..(ArchiveConfig.TAGS_PER_LINE-1)] if taglist.size > ArchiveConfig.TAGS_PER_LINE
    taglist
  end
  
  def fandom_tags
    self.fandoms.by_name
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
    if self.preview_mode
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
    tag_array = incoming_tags.is_a?(String) ? incoming_tags.split(ArchiveConfig.DELIMITER_FOR_INPUT) : incoming_tags
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
  
end