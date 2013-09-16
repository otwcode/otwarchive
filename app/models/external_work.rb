include UrlHelpers
class ExternalWork < ActiveRecord::Base
  
  include Taggable
  include Bookmarkable

  attr_protected :summary_sanitizer_version
  
  has_many :related_works, :as => :parent  
  
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings, :source => :tagger, :source_type => 'Tag'
  
  has_many :filter_taggings, :as => :filterable, :dependent => :destroy
  has_many :filters, :through => :filter_taggings

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

  belongs_to :language
  
  scope :duplicate, :group => "url HAVING count(DISTINCT id) > 1"

  AUTHOR_LENGTH_MAX = 500
  
  validates_presence_of :title
  validates_length_of :title, :minimum => ArchiveConfig.TITLE_MIN, 
    :too_short=> ts("must be at least %{min} characters long.", :min => ArchiveConfig.TITLE_MIN)
  validates_length_of :title, :maximum => ArchiveConfig.TITLE_MAX, 
    :too_long=> ts("must be less than %{max} characters long.", :max => ArchiveConfig.TITLE_MAX)
    
  validates_length_of :summary, :allow_blank => true, :maximum => ArchiveConfig.SUMMARY_MAX, 
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.SUMMARY_MAX)
      
  validates_presence_of :author
  validates_length_of :author, :maximum => AUTHOR_LENGTH_MAX, 
    :too_long=> ts("must be less than %{max} characters long.", :max => AUTHOR_LENGTH_MAX)

  # TODO: External works should have fandoms, but they currently don't get added through the
  # post new work form so we can't validate them
  #validates_presence_of :fandoms

  before_validation :cleanup_url
  validates :url, :presence => true, :url_format => true, :url_active => true
  def cleanup_url
    self.url = reformat_url(self.url) if self.url
  end
    
  # Sets the dead? attribute to true if the link is no longer active
  def set_url_status
    self.update_attribute(:dead, true) unless url_active?(self.url)
  end
  
  
  ########################################################################
  # VISIBILITY
  ########################################################################
  # Adapted from work.rb
  
  scope :visible_to_all, where(:hidden_by_admin => false)
  scope :visible_to_registered_user, where(:hidden_by_admin => false)
  scope :visible_to_admin, where("")

  # a complicated dynamic scope here: 
  # if the user is an Admin, we use the "visible_to_admin" scope
  # if the user is not a logged-in User, we use the "visible_to_all" scope
  # otherwise, we use a join to get userids and then get all posted works that are either unhidden OR belong to this user.
  # Note: in that last case we have to use select("DISTINCT works.") because of cases where the same user appears twice
  # on a work.
  scope :visible_to_user, lambda {|user| user.is_a?(Admin) ? visible_to_admin : visible_to_all}
    
  # Use the current user to determine what external works are visible
  scope :visible, visible_to_user(User.current_user)
  
  # Visible unless we're hidden by admin, in which case only an Admin can see.
  def visible?(user=User.current_user)
    self.hidden_by_admin? ? user.kind_of?(Admin) : true
  end
  # FIXME - duplicate of above but called in different ways in different places
  def visible(user=User.current_user)
    self.hidden_by_admin? ? user.kind_of?(Admin) : true
  end
   
  
  #######################################################################
  # TAGGING
  # External works are taggable objects.
  ####################################################################### 
 
  # FILTERING CALLBACKS
  after_save :check_filter_taggings
  
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
  
  # Assign the bookmarks and related works of other external works
  # to this one, and then delete them
  # TODO: use update_all instead?
  def merge_similar(externals)
    for external_work in externals
      unless external_work == self
        if external_work.bookmarks
          external_work.bookmarks.each do |bookmark|
            bookmark.bookmarkable = self
            bookmark.save!
          end
        end
        if external_work.related_works
          external_work.related_works.each do |related_work|
            related_work.parent = self
            related_work.save!
          end        
        end
        external_work.reload
        if external_work.bookmarks.empty? && external_work.related_works.empty?
          external_work.destroy
        end
      end
    end
  end

  def tag_groups
    self.tags.group_by { |t| t.type.to_s }
  end
   
end
