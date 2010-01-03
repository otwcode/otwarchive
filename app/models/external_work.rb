class ExternalWork < ActiveRecord::Base
  has_bookmarks
  has_many :user_tags, :through => :bookmarks, :source => :tags
  
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings, :source => :tagger, :source_type => 'Tag'
  has_many :common_taggings, :as => :filterable
  has_many :common_tags, :through => :common_taggings
  
  has_many :filter_taggings, :as => :filterable, :dependent => :destroy
  has_many :filters, :through => :filter_taggings

  has_many :ratings, :through => :taggings, :source => :tagger, :source_type => 'Rating', :before_remove => :remove_filter_tagging
  has_many :categories, :through => :taggings, :source => :tagger, :source_type => 'Category', :before_remove => :remove_filter_tagging
  has_many :fandoms, :through => :taggings, :source => :tagger, :source_type => 'Fandom', :before_remove => :remove_filter_tagging
  has_many :pairings, :through => :taggings, :source => :tagger, :source_type => 'Pairing', :before_remove => :remove_filter_tagging
  has_many :characters, :through => :taggings, :source => :tagger, :source_type => 'Character', :before_remove => :remove_filter_tagging
  has_many :ambiguities, :through => :taggings, :source => :tagger, :source_type => 'Ambiguity', :before_remove => :remove_filter_tagging
  attr_accessor :ambiguous_tags

  AUTHOR_LENGTH_MAX = 500
  
  validates_presence_of :title
  validates_length_of :title, :minimum => ArchiveConfig.TITLE_MIN, 
    :too_short=> t('title_too_short', :default => "must be at least {{min}} characters long.", :min => ArchiveConfig.TITLE_MIN)
  validates_length_of :title, :maximum => ArchiveConfig.TITLE_MAX, 
    :too_long=> t('title_too_long', :default => "must be less than {{max}} characters long.", :max => ArchiveConfig.TITLE_MAX)
    
  validates_length_of :summary, :allow_blank => true, :maximum => ArchiveConfig.SUMMARY_MAX, 
    :too_long => t('summary_too_long', :default => "must be less than {{max}} characters long.", :max => ArchiveConfig.SUMMARY_MAX)
      
  validates_presence_of :url
  
  validates_presence_of :author
  validates_length_of :author, :maximum => AUTHOR_LENGTH_MAX, 
    :too_long=> t('author_too_long', :default => "must be less than {{max}} characters long.", :max => AUTHOR_LENGTH_MAX)

  before_save :validate_url
  
  # Standardizes format of urls so they're easier to validate and compare
  def self.format_url(url)
    url = "http://" + url if /http/.match(url[0..3]).nil?
    url.chop! if url.last == "/"
    url  
  end 
  
  # Makes sure urls are valid and checks to see if they're active or not
  def validate_url
    self.url = ExternalWork.format_url(self.url)
    errors.add_to_base(t('invalid_url', :default => "Not a valid URL")) unless self.url_active?
  end
  
  # Sets the dead? attribute to true if the link is no longer active
  def set_url_status
    self.update_attribute(:dead, true) unless self.url_active?
  end
  
  # Checks the status of the webpage at the external work's url
  def url_active?
    begin
      response = Net::HTTP.get_response URI.parse(self.url)
      active_status = %w(200 301 302)
      active_status.include? response.code
    rescue
      false
    end          
  end
  
  
  ########################################################################
  # VISIBILITY
  ########################################################################
  # Adapted from work.rb
  
  def self.visible(options = {})
    current_user=User.current_user
    with_scope :find => options do
      find(:all).collect {|b| b if b.visible(current_user)}.compact
    end
  end
  
  def visible(current_user=User.current_user)
    if current_user == :false || !current_user
      return self unless self.hidden_by_admin
    elsif !self.hidden_by_admin
      return self      
    elsif self.hidden_by_admin?
      return self if current_user.kind_of?(Admin)
    end
  end

  def visible?(user=User.current_user)
    self.visible(user) == self
  end
   
  
  #######################################################################
  # TAGGING
  # External works are taggable objects.
  ####################################################################### 

  before_save :update_ambiguous_tags

  # string methods
  # (didn't use define_method, despite the redundancy, because it doesn't cache in development)
  def rating_string
    self.ratings.string
  end
  def category_string
    self.categories.string
  end
  def fandom_string
    self.fandoms.string
  end
  def pairing_string
    self.pairings.string
  end
  def character_string
    self.characters.string
  end
  def ambiguity_string
    self.ambiguities.string
  end

  # _string= methods
  # always use string= methods to set tags
  # << and = don't trigger callbacks to update common_tags
  # or call after_destroy on taggings
  # see rails bug http://dev.rubyonrails.org/ticket/7743
  def rating_string=(tag_string)
    tag = Rating.find_or_create_by_name(tag_string)
    return if self.ratings == [tag]
    Tagging.find_by_tag(self, self.ratings.first).destroy unless self.ratings.blank?
    self.ratings = [tag] if tag.is_a?(Rating)
  end

  def category_string=(tag_string)
    tag = Category.find_or_create_by_name(tag_string)
    return if self.categories == [tag]
    Tagging.find_by_tag(self, self.categories.first).destroy unless self.categories.blank?
    self.categories = [tag] if tag.is_a?(Category)
  end

  def fandom_string=(tag_string)
    tags = []
    ambiguities = []
    tag_string.split(ArchiveConfig.DELIMITER_FOR_INPUT).each do |string|
      string.squish!
      tag = Fandom.find_or_create_by_name(string)
      tags << tag if tag.is_a?(Fandom)
      ambiguities << tag if tag.is_a?(Ambiguity)
    end
    self.add_to_ambiguity(ambiguities)
    remove = self.fandoms - tags
    remove.each do |tag|
      Tagging.find_by_tag(self, tag).destroy
    end
    self.fandoms = tags
  end

  def pairing_string=(tag_string)
    tags = []
    ambiguities = []
    tag_string.split(ArchiveConfig.DELIMITER_FOR_INPUT).each do |string|
      string.squish!
      tag = Pairing.find_or_create_by_name(string)
      tags << tag if tag.is_a?(Pairing)
      ambiguities << tag if tag.is_a?(Ambiguity)
    end
    self.add_to_ambiguity(ambiguities)
    remove = self.pairings - tags
    remove.each do |tag|
      Tagging.find_by_tag(self, tag).destroy
    end
    self.pairings = tags
  end

  def character_string=(tag_string)
    tags = []
    ambiguities = []
    tag_string.split(ArchiveConfig.DELIMITER_FOR_INPUT).each do |string|
      string.squish!
      tag = Character.find_or_create_by_name(string)
      tags << tag if tag.is_a?(Character)
      ambiguities << tag if tag.is_a?(Ambiguity)
    end
    self.add_to_ambiguity(ambiguities)
    remove = self.characters - tags
    remove.each do |tag|
      Tagging.find_by_tag(self, tag).destroy
    end
    self.characters = tags
  end

  def ambiguity_string=(tag_string)
    tags = []
    tag_string.split(ArchiveConfig.DELIMITER_FOR_INPUT).each do |string|
      string.squish!
      tag = Ambiguity.find_or_create_by_name(string)
      tags << tag if tag.is_a?(Ambiguity)
    end
    self.add_to_ambiguity(tags.compact)
  end

  def add_to_ambiguity(tags)
    if self.ambiguous_tags
      self.ambiguous_tags << tags
    else
      self.ambiguous_tags = tags
    end
  end

  # a work can only have one rating, so using first will work
  def adult?
    # should always have a rating, if it doesn't err conservatively
    return true if self.ratings.blank?
    self.ratings.first.adult?
  end

  def update_common_tags
    # new_tags = []
    # # work.tags is empty at this point?!?!?
    # Tagging.find_all_by_taggable_id_and_taggable_type(self.id, 'external_work').each do |tagging|
    #   new_tags << tagging.tagger.common_tags_to_add rescue nil
    # end
    # new_tags = new_tags.flatten.uniq.compact
    # old_tags = self.common_tags
    # self.common_tags.delete(old_tags - new_tags)
    # self.common_tags << (new_tags - old_tags)
    # self.common_tags
  end

  def update_ambiguous_tags
    new_ambiguities = ambiguous_tags.flatten.uniq.compact if ambiguous_tags
    unless ambiguous_tags.blank?
      old_ambiguities = self.ambiguities
      (old_ambiguities - new_ambiguities).each do |tag|
        Tagging.find_by_tag(self, tag).destroy
      end
    end
    self.ambiguities = new_ambiguities if new_ambiguities
    #self.update_common_tags
  end

  def cast_tags
    # we combine pairing and character tags up to the limit
    characters = self.tags.select{|tag| tag.type == "Character"}.sort || []
    pairings = self.tags.select{|tag| tag.type == "Pairing"}.sort || []
    return [] if pairings.empty? && characters.empty?
    canonical_pairings = Pairing.canonical.find(pairings.collect(&:merger_id).compact.uniq)
    all_pairings = (pairings + canonical_pairings).flatten.uniq.compact

    #pairing_characters = all_pairings.collect{|p| p.all_characters}.flatten.uniq.compact
    pairing_characters = Character.by_pairings(all_pairings)

    cast = pairings + characters - pairing_characters
    if cast.size > ArchiveConfig.TAGS_PER_LINE
      cast = cast[0..(ArchiveConfig.TAGS_PER_LINE-1)]
    end

    return cast
  end

  def fandom_tags
    self.tags.select{|tag| tag.type == "Fandom"}.sort
  end  
  
 
  # FILTERING CALLBACKS
  before_save :check_filter_taggings
  
  # Add and remove filter taggings as tags are added and removed
  def check_filter_taggings
    current_filters = self.tags.collect{|tag| tag.canonical? ? tag : tag.merger }.compact
    current_filters.each {|filter| self.add_filter_tagging(filter)}
    filters_to_remove = self.filters - current_filters
    unless filters_to_remove.empty?
      filters_to_remove.each {|filter| self.remove_filter_tagging(filter)}
    end
    return true    
  end
  
  # Creates a filter_tagging relationship between the work and the tag or its canonical synonym
  def add_filter_tagging(tag)
    filter = tag.canonical? ? tag : tag.merger
    if filter && !self.filters.include?(filter)
      self.filters << filter
      filter.reset_filter_count 
    end
  end
  
  # Removes filter_tagging relationship unless the work is tagged with more than one synonymous tags
  def remove_filter_tagging(tag)
    filter = tag.canonical? ? tag : tag.merger
    if filter && (self.tags & tag.synonyms).empty? && self.filters.include?(filter)
      self.filters.delete(filter)
      filter.reset_filter_count
    end  
  end
   
end
