class Work < ActiveRecord::Base

  ########################################################################
  # ASSOCIATIONS
  ########################################################################

  has_many :creatorships, :as => :creation
  has_many :pseuds, :through => :creatorships

  has_many :chapters, :dependent => :destroy
  validates_associated :chapters

  has_many :serial_works, :dependent => :destroy
  has_many :series, :through => :serial_works

  has_many :related_works, :as => :parent

  has_bookmarks
  has_many :user_tags, :through => :bookmarks, :source => :tags

  has_many :common_taggings, :as => :filterable
  has_many :common_tags, :through => :common_taggings

  has_many :taggings, :as => :taggable
  has_many :tags, :through => :taggings, :source => :tagger, :source_type => 'Tag'

  has_many :ratings, :through => :taggings, :source => :tagger, :source_type => 'Rating'
  has_many :categories, :through => :taggings, :source => :tagger, :source_type => 'Category'
  has_many :warnings, :through => :taggings, :source => :tagger, :source_type => 'Warning'
  has_many :fandoms, :through => :taggings, :source => :tagger, :source_type => 'Fandom'
  has_many :pairings, :through => :taggings, :source => :tagger, :source_type => 'Pairing'
  has_many :characters, :through => :taggings, :source => :tagger, :source_type => 'Character'
  has_many :freeforms, :through => :taggings, :source => :tagger, :source_type => 'Freeform'
  has_many :ambiguities, :through => :taggings, :source => :tagger, :source_type => 'Ambiguity'

  acts_as_commentable

  belongs_to :locale, :foreign_key => 'language_id', :class_name => 'Locale'

  ########################################################################
  # VIRTUAL ATTRIBUTES
  ########################################################################

  # Virtual attribute to use as a placeholder for pseuds before the work has been saved
  # Can't write to work.pseuds until the work has an id
  attr_accessor :authors
  attr_accessor :toremove
  attr_accessor :invalid_pseuds
  attr_accessor :ambiguous_pseuds
  attr_accessor :new_parent, :url_for_parent
  attr_accessor :ambiguous_tags

  ########################################################################
  # VALIDATION
  ########################################################################
  validates_presence_of :title
  validates_length_of :title,
    :minimum => ArchiveConfig.TITLE_MIN, :too_short=> "must be at least " + ArchiveConfig.TITLE_MIN.to_s + " letters long."

  validates_length_of :title,
    :maximum => ArchiveConfig.TITLE_MAX, :too_long=> "must be less than " + ArchiveConfig.TITLE_MAX.to_s + " letters long."

  validates_length_of :summary,
    :allow_blank => true,
    :maximum => ArchiveConfig.SUMMARY_MAX, :too_long => "must be less than " + ArchiveConfig.SUMMARY_MAX.to_s + " letters long."

  validates_length_of :notes,
    :allow_blank => true,
    :maximum => ArchiveConfig.NOTES_MAX, :too_long => "must be less than " + ArchiveConfig.NOTES_MAX.to_s + " letters long."

  #temporary validation to let people know they can't enter external urls yet
  validates_format_of :parent_url, :with => Regexp.new(ArchiveConfig.APP_URL, true),
    :allow_blank => true, :message => "can only be in the archive for now - we're working on expanding that!"

  # Checks that work has at least one author
  def validate_authors
    if self.authors.blank? && self.pseuds.empty?
      errors.add_to_base("Work must have at least one author.")
      return false
    elsif !self.invalid_pseuds.blank?
      errors.add_to_base("These pseuds are invalid: " + self.invalid_pseuds.inspect)
    end
  end

  # Makes sure the title has no leading spaces
  def clean_and_validate_title
    unless self.title.blank?
      self.title = self.title.strip
      if self.title.length < ArchiveConfig.TITLE_MIN
        errors.add_to_base("Title must be at least " + ArchiveConfig.TITLE_MIN.to_s + " characters long without leading spaces.")
        return false
      end
    end
  end

  def validate_published_at
    to = DateTime.now
    return false unless self.published_at
    if self.published_at > to
      errors.add_to_base("Publication date can't be in the future.")
      return false
    end
  end

  # rephrases the "chapters is invalid" message
  def after_validation
    if self.errors.on(:chapters)
      self.errors.add(:base, "Please enter your story in the text field below.")
      self.errors.delete(:chapters)
    end
  end



  ########################################################################
  # HOOKS
  # These are methods that run before/after saves and updates to ensure
  # consistency and that associated variables are updated.
  ########################################################################
  before_save :validate_authors, :clean_and_validate_title, :validate_published_at

  before_save :set_word_count, :set_language, :post_first_chapter

  after_save :save_creatorships, :save_chapters, :save_parents

  # before_save :validate_tags # Enigel's feeble attempt

  before_update :validate_tags

  before_save :update_ambiguous_tags

  ########################################################################
  # AUTHORSHIP
  ########################################################################


  # Virtual attribute for pseuds
  def author_attributes=(attributes)
    self.authors ||= []
    wanted_ids = attributes[:ids]
    wanted_ids.each { |id| self.authors << Pseud.find(id) }
    # if current user has selected different pseuds
    current_user = User.current_user
    if current_user.is_a? User
      self.toremove = current_user.pseuds - wanted_ids.collect {|id| Pseud.find(id)}
    end
    attributes[:ambiguous_pseuds].each { |id| self.authors << Pseud.find(id) } if attributes[:ambiguous_pseuds]
    if attributes[:byline]
      results = Pseud.parse_bylines(attributes[:byline])
      self.authors << results[:pseuds]
      self.invalid_pseuds = results[:invalid_pseuds]
      self.ambiguous_pseuds = results[:ambiguous_pseuds]
    end
    self.authors.flatten!
    self.authors.uniq!
  end


  # Save creatorships (add the virtual authors to the real pseuds) after the work is saved
  def save_creatorships
    if self.authors
      new = self.authors - self.pseuds
      self.pseuds << new rescue nil
      self.chapters.first.pseuds << new rescue nil
      self.series.each {|series| series.pseuds << (self.authors - series.pseuds) rescue nil}
    end
    if self.toremove
      self.pseuds.delete(self.toremove)
      self.chapters.first.pseuds.delete(self.toremove)
      self.series.each {|series| series.pseuds.delete(self.toremove)} unless self.series.empty?
    end
  end


  ########################################################################
  # VISIBILITY
  ########################################################################

  def visible(current_user=User.current_user)
    if current_user == :false || !current_user
      return self if self.posted unless self.restricted || self.hidden_by_admin
    elsif self.posted && !self.hidden_by_admin
      return self
    elsif self.hidden_by_admin?
      return self if current_user.kind_of?(Admin) || current_user.is_author_of?(self)
    end
  end

  def visible?(user=User.current_user)
    self.visible(user) == self
  end

  ########################################################################
  # LANGUAGE
  ########################################################################


  # Associating works with languages.
  def set_language(lang = nil)
    if lang.nil?
      return if self.locale
      self.locale = Locale.find_main_cached
      # Setting all works to the default language until there's a better framework in place
      # for language preferences - elz, 3/7/09
      # self.locale = Locale.find_by_short(I18n.locale.to_s)
    else
      self.locale = lang
    end
  end



  ########################################################################
  # VERSIONS & REVISION DATES
  ########################################################################

  # provide an interface to increment major version number
  # resets minor_version to 0
  def update_major_version
    self.update_attributes({:major_version => self.major_version+1, :minor_version => 0})
  end

  # provide an interface to increment minor version number
  def update_minor_version
    self.update_attribute(:minor_version, self.minor_version+1)
  end

  def set_revised_at(datetime=self.published_at)
    if datetime.to_date == Date.today
      value = Time.now
    else
      value = datetime
    end
    self.update_attribute(:revised_at, value)
  end


  ########################################################################
  # SERIES
  ########################################################################

  # Virtual attribute for series
  def series_attributes=(attributes)
    new_series = Series.find(attributes[:id]) unless attributes[:id].blank?
    self.series << new_series unless (new_series.blank? || self.series.include?(new_series))
    unless attributes[:title].blank?
      new_series = Series.new
      new_series.title = attributes[:title]
      new_series.save
      self.series << new_series
    end
  end



  ########################################################################
  # CHAPTERS
  ########################################################################

  # Save chapter data when the work is updated
  def save_chapters
    self.chapters.first.save(false)
  end

  # If the work is posted, the first chapter should be posted too
  def post_first_chapter
    if self.posted? && !self.first_chapter.posted?
       chapter = self.first_chapter
       chapter.posted = true
       chapter.save(false)
    end
  end

  # Virtual attribute for first chapter
  def chapter_attributes=(attributes)
    self.new_record? ? self.chapters.build(attributes) : self.chapters.first.attributes = attributes
    self.chapters.first.posted = self.posted
  end

  # Virtual attribute for # of chapters
  def wip_length
    self.expected_number_of_chapters.nil? ? "?" : self.expected_number_of_chapters
  end

  def wip_length=(number)
    number = number.to_i
    self.expected_number_of_chapters = (number != 0 && number >= self.number_of_chapters) ? number : nil
  end

  # Get the total number of chapters for a work
  def number_of_chapters
     Chapter.maximum(:position, :conditions => {:work_id => self.id}) || 0
  end

  # Get the total number of posted chapters for a work
  def number_of_posted_chapters
     Chapter.maximum(:position, :conditions => {:work_id => self.id, :posted => true}) || 0
  end

  # Gets the current first chapter
  def first_chapter
    self.chapters.find(:first, :order => 'position ASC') || self.chapters.first
  end

  # Gets the current last chapter
  def last_chapter
    self.chapters.find(:first, :order => 'position DESC')
  end

  # Change the position of multiple chapters when one is deleted
  def adjust_chapters(position)
    Chapter.update_all("position = (position - 1)", ["work_id = (?) AND position > (?)", self.id, position])
  end

  # Reorders chapters based on form data
  # Removes changed chapters from array, sorts them in order of position, re-inserts them into the array and uses the array index values to determine the new positions
  def reorder_chapters(positions)
    chapters = self.chapters.find(:all, :conditions => {:posted => true}, :order => 'position')
    changed = {}
    positions.collect!(&:to_i).each_with_index do |new_position, old_position|
      if new_position != 0 && new_position <= self.number_of_posted_chapters && !changed.has_key?(new_position)
        changed.merge!({new_position => chapters[old_position]})
      end
    end
    chapters -= changed.values
    changed.sort.each {|pair| pair.first > chapters.length ? chapters << pair.last : chapters.insert(pair.first-1, pair.last)}
    chapters.each_with_index {|chapter, index| chapter.update_attribute(:position, index + 1)}
  end

  # Returns true if a work has or will have more than one chapter
  def chaptered?
    self.expected_number_of_chapters != 1
  end

  # Returns true if a work has more than one chapter
  def multipart?
    self.number_of_chapters > 1
  end

  # Returns true if a work is not yet complete
  def is_wip
    self.expected_number_of_chapters.nil? || self.expected_number_of_chapters != self.number_of_chapters
  end

  # Returns true if a work is complete
  def is_complete
    return !self.is_wip
  end

  # Set the value of word_count to reflect the length of the chapter content
  def set_word_count
    self.word_count = self.chapters.collect(&:word_count).compact.sum
  end

  #######################################################################
  # TAGGING
  # Works are taggable objects.
  #######################################################################

  # string methods
  # (didn't use define_method, despite the redundancy, because it doesn't cache in development)
  def rating_string
    self.ratings.string
  end
  def category_string
    self.categories.string
  end
  def warning_string
    self.warnings.string
  end
  def warning_strings
    self.warnings.map(&:name)
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
  def freeform_string
    self.freeforms.string
  end
  def ambiguity_string
    self.ambiguities.string
  end

  # _string= methods
  # always use string= methods to set tags
  # << and = don't trigger callbacks to update common_tags
  # see rails bug http://dev.rubyonrails.org/ticket/7743
  def rating_string=(tag_string)
    tag = Rating.find_or_create_by_name(tag_string)
    self.ratings = [tag] if tag.is_a?(Rating)
  end

  def category_string=(tag_string)
    tag = Category.find_or_create_by_name(tag_string)
    self.categories = [tag] if tag.is_a?(Category)
  end

  def warning_string=(tag_string)
    tags = []
    tag_string.split(ArchiveConfig.DELIMITER).each do |string|
      tag = Warning.find_or_create_by_name(string)
      tags << tag if tag.is_a?(Warning)
    end
    self.warnings = tags
  end

  def warning_strings=(array)
    tags = []
    array.each do |string|
      tag = Warning.find_or_create_by_name(string)
      tags << tag if tag.is_a?(Warning)
    end
    self.warnings = tags
  end

  def fandom_string=(tag_string)
    tags = []
    ambiguities = []
    tag_string.split(ArchiveConfig.DELIMITER).each do |string|
      tag = Fandom.find_or_create_by_name(string)
      tags << tag if tag.is_a?(Fandom)
      ambiguities << tag if tag.is_a?(Ambiguity)
    end
    self.add_to_ambiguity(ambiguities)
    self.fandoms = tags
  end

  def pairing_string=(tag_string)
    tags = []
    ambiguities = []
    tag_string.split(ArchiveConfig.DELIMITER).each do |string|
      tag = Pairing.find_or_create_by_name(string)
      tags << tag if tag.is_a?(Pairing)
      ambiguities << tag if tag.is_a?(Ambiguity)
    end
    self.add_to_ambiguity(ambiguities)
    self.pairings = tags
  end

  def character_string=(tag_string)
    tags = []
    ambiguities = []
    tag_string.split(ArchiveConfig.DELIMITER).each do |string|
      tag = Character.find_or_create_by_name(string)
      tags << tag if tag.is_a?(Character)
      ambiguities << tag if tag.is_a?(Ambiguity)
    end
    self.add_to_ambiguity(ambiguities)
    self.characters = tags
  end

  def freeform_string=(tag_string)
    tags = []
    ambiguities = []
    tag_string.split(ArchiveConfig.DELIMITER).each do |string|
      tag =  Freeform.find_or_create_by_name(string)
      tags << tag if tag.is_a?(Freeform)
      ambiguities << tag if tag.is_a?(Ambiguity)
    end
    self.add_to_ambiguity(ambiguities)
    self.freeforms = tags.compact - ambiguities
  end

  def ambiguity_string=(tag_string)
    tags = []
    tag_string.split(ArchiveConfig.DELIMITER).each do |string|
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


  # Check to see that a work is tagged appropriately
  def has_required_tags?
    return false if self.fandoms.blank?
    return false if self.warnings.blank?
    return false if self.ratings.blank?
    return false if self.categories.blank?
    return true
  end

  def validate_tags
    errors.add_to_base("Work must have required tags.") unless self.has_required_tags?
    self.has_required_tags?
  end

  def update_common_tags
    new_tags = []
    # work.tags is empty at this point?!?!?
    Tagging.find_all_by_taggable_id_and_taggable_type(self.id, 'work').each do |tagging|
      new_tags << tagging.tagger.common_tags_to_add rescue nil
    end
    new_tags = new_tags.flatten.uniq.compact
    old_tags = self.common_tags
    self.common_tags.delete(old_tags - new_tags)
    self.common_tags << (new_tags - old_tags)
    self.common_tags
  end

  def update_ambiguous_tags
    self.ambiguities = ambiguous_tags.flatten.uniq.compact if ambiguous_tags
    self.update_common_tags
  end

  def cast_tags
    # we combine pairing and character tags up to the limit
    characters = self.characters.sort || []
    pairings = self.pairings.sort || []
    return [] if pairings.empty? && characters.empty?
    canonical_pairings = pairings.collect{|p| p.merger}
    all_pairings = (pairings + canonical_pairings).flatten.uniq.compact

    pairing_characters = all_pairings.collect{|p| p.all_characters}.flatten.uniq.compact

    cast = pairings + characters - pairing_characters
    if cast.size > ArchiveConfig.TAGS_PER_LINE
      cast = cast[0..(ArchiveConfig.TAGS_PER_LINE-1)]
    end

    return cast
  end

  def freeform_tags
    warnings = self.warnings.sort || []
    freeform = self.freeforms.sort || []
    ambiguous = self.ambiguities.sort || []

    tags = warnings + freeform + ambiguous
    if tags.size > ArchiveConfig.TAGS_PER_LINE
      tags = tags[0..(ArchiveConfig.TAGS_PER_LINE-1)]
    end
    return tags
  end

  # for testing
  def add_default_tags
    self.fandom_string = "Test Fandom"
    self.rating_string = ArchiveConfig.RATING_TEEN_TAG_NAME
    self.warning_string = ArchiveConfig.WARNING_NONE_TAG_NAME
    self.category_string = ArchiveConfig.CATEGORY_GEN_TAG_NAME
    self.save
  end
  ################################################################################
  # COMMENTING & BOOKMARKS
  # We don't actually have comments on works currently but on chapters.
  # Comment support -- work acts as a commentable object even though really we
  # override to consolidate the comments on all the chapters.
  ################################################################################

  # Gets all comments for all chapters in the work
  def find_all_comments
    self.chapters.collect { |c| c.find_all_comments }.flatten
  end

  # Returns number of comments
  # Hidden and deleted comments are referenced in the view because of the threading system - we don't necessarily need to
  # hide their existence from other users
  def count_all_comments
    self.chapters.collect { |c| c.count_all_comments }.sum
  end

  # returns the top-level comments for all chapters in the work
  def comments
    self.chapters.collect { |c| c.comments }.flatten
  end

  # Returns the number of visible bookmarks
  def count_visible_bookmarks(current_user=:false)
    self.bookmarks.select {|b| b.visible(current_user) }.length
  end



  ########################################################################
  # RELATED WORKS
  # These are for inspirations/remixes/etc
  ########################################################################

  # Works this work belongs to through related_works
  def parents
    RelatedWork.find(:all, :conditions => {:work_id => self.id}, :include => :parent).collect(&:parent).uniq
  end

  # Works that belong to this work through related_works
  def children
    RelatedWork.find(:all, :conditions => {:parent_id => self.id}, :include => :work).collect(&:work).uniq
  end

  # Works that belongs to this work and which have been approved for linking back
  def approved_children
    RelatedWork.find(:all, :conditions => {:parent_id => self.id, :reciprocal => true}, :include => :work).collect(&:work).uniq
  end

  # Virtual attribute for parent work, via related_works
  def parent_url
    self.url_for_parent
  end

  def parent_url=(url)
    self.url_for_parent = url
    unless url.blank?
      if url.include?(ArchiveConfig.APP_URL)
        id = url.match(/works\/\d+/).to_a.first
        id = id.split("/").last unless id.nil?
        self.new_parent = Work.find(id)
      else
        #TODO: handle related works that are not in the archive
      end
    end
  end

  # Save relationship to parent work if applicable
  def save_parents
    if self.new_parent and !(self.parents.include?(self.new_parent))
      relationship = self.new_parent.related_works.build :work_id => self.id
      relationship.save(false)
    end
  end



  #################################################################################
  #
  # SEARCH & FIND
  # In this section we define various named scopes that can be chained together
  # to do finds in the database, as well as settings for the ThinkingSphinx
  # plugin that connects us to the Sphinx search engine.
  #
  #################################################################################

  AUTHOR_TO_SORT_ON ="trim(leading '/' from
                        trim(leading '.' from
                          trim(leading '\\\'' from
                            trim(leading '\\\"' from
                              trim(leading '!' from
                                trim(leading '?' from
                                  trim(leading '=' from
                                    trim(leading '-' from
                                      trim(leading '+' from
                                        lower(pseuds.name)
                                      )
                                    )
                                  )
                                )
                              )
                            )
                          )
                        )
                      )"


  TITLE_TO_SORT_ON_CASE ="case
                          when substring_index(lower(works.title), ' ', 1) in ('a', 'an', 'the')
                          then lower(concat(substring(works.title, instr(works.title, ' ') + 1), ', ', substring_index(works.title, ' ', 1) ))
                          else
                            trim(leading '/' from
                              trim(leading '.' from
                                trim(leading '\\\'' from
                                  trim(leading '\\\"' from
                                    lower(works.title)
                                  )
                                )
                              )
                            )
                          end"


  # Index for Thinking Sphinx
  define_index do

    # fields
    indexes summary
    indexes notes
    indexes title, :sortable => true

    # associations
    indexes chapters.content, :as => 'chapter_content'
    indexes tags.name, :as => 'tag_name'
    indexes pseuds.name, :as => 'pseud_name'

    # attributes
    has :id, :as => :work_ids
    has word_count, revised_at
    has tags(:id), :as => :tag_ids
    has TITLE_TO_SORT_ON_CASE, :as => :title_for_sort, :type => :string
    has AUTHOR_TO_SORT_ON, :as => :author_for_sort, :type => :string

    # properties
    set_property :delta => true
    set_property :field_weights => { :tag_name => 10,
                                     :title => 10, :pseud_name => 10,
                                     :summary => 5, :notes => 5,
                                     :chapter_content => 1}
  end

  protected

  # a string for use in :joins => clause to add ownership lookup
  OWNERSHIP_JOIN = "INNER JOIN creatorships ON (creatorships.creation_id = works.id AND creatorships.creation_type = 'Work')
                    INNER JOIN pseuds ON creatorships.pseud_id = pseuds.id
                    INNER JOIN users ON pseuds.user_id = users.id"

  COMMON_TAG_JOIN = "INNER JOIN common_taggings ON (works.id = common_taggings.filterable_id AND common_taggings.filterable_type = 'Work')
                  INNER JOIN tags ON common_taggings.common_tag_id = tags.id"


  VISIBLE_TO_ALL_CONDITIONS = {:posted => true, :restricted => false, :hidden_by_admin => false}

  VISIBLE_TO_USER_CONDITIONS = {:posted => true, :hidden_by_admin => false}

  VISIBLE_TO_ADMIN_CONDITIONS = {:posted => true}

  public

  named_scope :ordered_by_author, lambda{|sort_direction|
    {
      #:joins => OWNERSHIP_JOIN + " " + COMMON_TAG_JOIN,
      :order => AUTHOR_TO_SORT_ON + " " + "#{(sort_direction.upcase == 'DESC' ? 'DESC' : 'ASC')}"
    }
  }

  named_scope :ordered_by_title, lambda{ |sort_direction|
    {
      :order => TITLE_TO_SORT_ON_CASE + " " + "#{(sort_direction.upcase == 'DESC' ? 'DESC' : 'ASC')}"
    }
  }

  named_scope :ordered, lambda {|sort_field, sort_direction|
    {
      :order => "works.#{(Work.column_names.include?(sort_field) ? sort_field : 'revised_at')}" +
                " " +
                "#{(sort_direction.upcase == 'DESC' ? 'DESC' : 'ASC')}"
    }
  }
  named_scope :limited, lambda {|limit|
    {:limit => limit.kind_of?(Fixnum) ? limit : 5}
  }

  named_scope :recent, :order => 'works.revised_at DESC', :limit => 5
  named_scope :posted, :conditions => {:posted => true}
  named_scope :unposted, :conditions => {:posted => false}
  named_scope :restricted , :conditions => {:restricted => true}
  named_scope :unrestricted, :conditions => {:restricted => true}
  named_scope :hidden, :conditions => {:hidden_by_admin => true}
  named_scope :unhidden, :conditions => {:hidden_by_admin => false}
  named_scope :visible_to_owner, :conditions => VISIBLE_TO_ADMIN_CONDITIONS
  named_scope :visible_to_user, :conditions => VISIBLE_TO_USER_CONDITIONS
  named_scope :visible_to_all, :conditions => VISIBLE_TO_ALL_CONDITIONS
  named_scope :all_with_tags, :include => [:tags]


  # These named scopes include the OWNERSHIP_JOIN so they can be chained
  # with "visible" (visible must go first) without clobbering the combined
  # joins.
  named_scope :with_all_tags, lambda {|tags_to_find|
    {
      :select => "DISTINCT works.*",
      :joins => COMMON_TAG_JOIN,
      :conditions => ["tags.id in (?)", tags_to_find.collect(&:id)],
      :group => "works.id HAVING count(DISTINCT tags.id) = #{tags_to_find.size}"
    }
  }

  named_scope :with_any_tags, lambda {|tags_to_find|
    {
      :select => "DISTINCT works.*",
      :joins => COMMON_TAG_JOIN,
      :conditions => ["tags.id in (?)", tags_to_find.collect(&:id)],
    }
  }

  named_scope :with_all_tag_ids, lambda {|tag_ids_to_find|
    {
      :select => "DISTINCT works.*",
      :joins => COMMON_TAG_JOIN,
      :conditions => ["tags.id in (?)", tag_ids_to_find],
      :group => "works.id HAVING count(DISTINCT tags.id) = #{tag_ids_to_find.size}"
    }
  }

  named_scope :with_any_tag_ids, lambda {|tag_ids_to_find|
    {
      :select => "DISTINCT works.*",
      :joins => COMMON_TAG_JOIN,
      :conditions => ["tags.id in (?)", tag_ids_to_find],
    }
  }

  # Skip the ownership join if you're combining it with owned_by, or the two joins will conflict
  named_scope :visible, lambda { |*skip_ownership|
    {
     :select => "DISTINCT works.*",
     :joins => (skip_ownership.empty? ? OWNERSHIP_JOIN : '')
    }.merge( (User.current_user && User.current_user.kind_of?(Admin)) ?
      { :conditions => {:posted => true} } :
      ( (User.current_user && User.current_user != :false) ?
        {:conditions => ['works.posted = ? AND (works.hidden_by_admin = ? OR users.id = ?)', true, false, User.current_user.id] } :
        {:conditions => VISIBLE_TO_ALL_CONDITIONS })
      )
  }

  named_scope :ids_only, :select => "DISTINCT works.id"

  named_scope :tags_with_count, lambda {|*args|
    {
      :select => "tags.type as tag_type, tags.id as tag_id, tags.name as tag_name, count(distinct works.id) as count",
      :joins => COMMON_TAG_JOIN,
      :group => "tags.name",
      :order => "tags.type, tags.name ASC"
    }.merge(args.first.size > 0 ? {:conditions => ["works.id in (?)", args.first]} : {})
  }

  named_scope :owned_by, lambda {|user|
    {
      :select => "DISTINCT works.*",
      :joins => OWNERSHIP_JOIN,
      :conditions => ['users.id = ?', user.id]
    }
  }

  named_scope :owned_by_conditions, lambda {|user|
    {
      :joins => OWNERSHIP_JOIN,
      :conditions => ['users.id = ?', user.id]
    }
  }

  named_scope :written_by, lambda {|pseuds|
    {
      :select => "DISTINCT works.*",
      :joins => "INNER JOIN creatorships ON (creatorships.creation_id = works.id AND creatorships.creation_type = 'Work')
                 INNER JOIN pseuds ON creatorships.pseud_id = pseuds.id",
      :conditions => ['pseuds.id IN (?)', pseuds.collect(&:id)]
    }
  }

  named_scope :written_by_conditions, lambda {|pseuds|
    {
      :joins => OWNERSHIP_JOIN,
      :conditions => ['pseuds.id IN (?)', pseuds.collect(&:id)]
    }
  }

  named_scope :written_by_id_conditions, lambda {|pseud_ids|
    {
      :joins => OWNERSHIP_JOIN,
      :conditions => ['pseuds.id IN (?)', pseud_ids]
    }
  }

  # returns an array, must come last
  # TODO: if you know how to turn this into a named_scope, please do!
  # find all the works that do not have a tag in the given category (i.e. no fandom, no characters etc.)
  def self.no_tags(tag_category, options = {})
    tags = tag_category.tags
    with_scope :find => options do
      find(:all).collect {|w| w if (w.tags & tags).empty? }.compact.uniq
    end
  end

  def self.search_with_sphinx(options)

    # sphinx ordering must be done on attributes
    order_clause = ""
    case options[:sort_column]
    when "title"
      order_clause = "title_for_sort "
    when "author"
      order_clause = "author_for_sort "
    when "word_count"
      order_clause = "word_count "
    when "date"
      order_clause = "revised_at "
    end

    if !order_clause.blank?
      sort_dir_sym = "sort_direction_for_#{options[:sort_column]}".to_sym
      order_clause += (options[sort_dir_sym] == "ASC" ? "ASC" : "DESC")
    end

    conditions_clause = {}
    command = 'Work.ids_only'
    visible = '.visible'
    visible_without_owners = '.visible(skip_owners = true)'
    tags = '.with_all_tag_ids(options[:selected_tags])'
    written = '.written_by_id_conditions(options[:selected_pseuds])'

    if options[:selected_tags] && options[:selected_pseuds]
      command += written + visible_without_owners + tags
    elsif options[:selected_tags]
      command += visible + tags
    elsif options[:selected_pseuds]
      command += written + visible_without_owners
    else
      command += visible
    end
    ids = eval("#{command}").collect(&:id)
    conditions_clause = ids.empty? ? {:work_ids => '-1'}  : {:work_ids => ids}

    search_options = {:conditions => conditions_clause,
                      :per_page => (options[:per_page] || ArchiveConfig.ITEMS_PER_PAGE),
                      :page => options[:page]}
    search_options.merge!({:order => order_clause}) if !order_clause.blank?

    logger.info "\n\n\n\n*+*+*+*+ search_options: " + search_options.to_yaml

    Work.search(options[:query], search_options)
  end

  # FIXME: nested scopes aren't really working on User- and Pseud-specific filtering
  def self.find_with_options(options = {})
    command = ''
    visible = '.visible'
    visible_without_owners = '.visible(skip_owners = true)'
    tags = '.with_all_tag_ids(options[:selected_tags])'
    written = '.written_by_id_conditions(options[:selected_pseuds])'
    owned = '.owned_by_conditions(options[:user])'
    sort = case options[:sort_column]
            when 'date'
              then '.ordered("revised_at", options[:sort_direction])'
            when 'author'
              then '.ordered_by_author(options[:sort_direction])'
            when 'title'
              then '.ordered_by_title(options[:sort_direction])'
            else
              '.ordered(options[:sort_column], options[:sort_direction])'
    end

    sort_and_paginate = sort + '.paginate(options[:page_args])'

    @works = []
    @pseuds = []
    @filters = []

    # 1. individual user
    # 1.1 individual pseud
    # 1.1.1 and tags
    # 1.2 and tags
    # 2. tags
    # 3. all

    if !options[:user].nil? && !options[:selected_pseuds].empty? && !options[:selected_tags].empty?
      # We have an indiv. user, selected pseuds and selected tags
      command << owned + written + visible_without_owners + tags
    elsif !options[:user].nil? && !options[:selected_pseuds].empty?
      # We have an indiv. user, selected pseuds but no selected tags
      command << owned + written + visible_without_owners
    elsif !options[:user].nil? && !options[:selected_tags].empty?
      # filtered results on a user's works page
      # no pseuds but a specific user, and selected tags
      command << owned + visible_without_owners + tags
    elsif !options[:user].nil?
      # a user's default works page
      command << owned + visible_without_owners
      @pseuds = options[:user].pseuds
    elsif !options[:selected_tags].empty?
      # no user but selected tags
      command << visible + tags
    else
      # all visible works
      command << visible
    end

    @works = eval("Work#{command + sort_and_paginate}")
    # what I'm trying to achieve here
    # is to add the co-authors of the displayed works to the available list of pseuds to filter on
    if !options[:user].nil?
      @pseuds << Pseud.on_works(@works) # options[:user].pseuds.on_works(@works)
      @pseuds.flatten!.uniq!
    end

    unless @works.empty?
      ids = eval("Work.ids_only#{command}").collect(&:id)
      @filters = build_filters_hash(Work.tags_with_count(ids))
    end

    return @works, @filters, @pseuds
  end

  def self.build_filters_hash(filters_array)
    # this takes an array from tags_with_count and turns it into a hash of hashes indexed
    # by tag.type
    filters_hash = {}
    filters_array.each do |filter|
      begin
        count = filter.count
      rescue
        count = 0
      end
      tmphash = {:name => filter.tag_name, :id => filter.tag_id.to_s, :count => count}
      key = filter.tag_type
      if filters_hash[key]
        filters_hash[key] << tmphash
      else
        filters_hash[key] = [tmphash]
      end
    end
    return filters_hash
  end

  # this is the method which is called from the works controller
  # after a sphinx search retrieved the works
  def self.get_filters(works_to_filter)
    ids = works_to_filter.collect(&:id)
    @filters = build_filters_hash(Work.tags_with_count(ids))
    return @filters
  end

  # sort works by title
  def <=>(another_work)
    title.strip.downcase <=> another_work.strip.downcase
  end

end
