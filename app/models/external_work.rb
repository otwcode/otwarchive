include UrlHelpers
class ExternalWork < ActiveRecord::Base
  
  include Taggable
  
  has_bookmarks
  has_many :user_tags, :through => :bookmarks, :source => :tags
  
  has_many :related_works, :as => :parent  
  
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings, :source => :tagger, :source_type => 'Tag'
  
  has_many :filter_taggings, :as => :filterable, :dependent => :destroy
  has_many :filters, :through => :filter_taggings

  has_many :ratings, :through => :taggings, :source => :tagger, :source_type => 'Rating', :before_remove => :remove_filter_tagging
  has_many :categories, :through => :taggings, :source => :tagger, :source_type => 'Category', :before_remove => :remove_filter_tagging
  has_many :warnings, :through => :taggings, :source => :tagger, :source_type => 'Warning', :before_remove => :remove_filter_tagging
  has_many :fandoms, :through => :taggings, :source => :tagger, :source_type => 'Fandom', :before_remove => :remove_filter_tagging
  has_many :relationships, :through => :taggings, :source => :tagger, :source_type => 'Relationship', :before_remove => :remove_filter_tagging
  has_many :characters, :through => :taggings, :source => :tagger, :source_type => 'Character', :before_remove => :remove_filter_tagging
  has_many :freeforms, :through => :taggings, :source => :tagger, :source_type => 'Freeform', :before_remove => :remove_filter_tagging

  scope :duplicate, :group => "url HAVING count(DISTINCT id) > 1"

  AUTHOR_LENGTH_MAX = 500
  
  validates_presence_of :title
  validates_length_of :title, :minimum => ArchiveConfig.TITLE_MIN, 
    :too_short=> t('title_too_short', :default => "must be at least %{min} characters long.", :min => ArchiveConfig.TITLE_MIN)
  validates_length_of :title, :maximum => ArchiveConfig.TITLE_MAX, 
    :too_long=> t('title_too_long', :default => "must be less than %{max} characters long.", :max => ArchiveConfig.TITLE_MAX)
    
  validates_length_of :summary, :allow_blank => true, :maximum => ArchiveConfig.SUMMARY_MAX, 
    :too_long => t('summary_too_long', :default => "must be less than %{max} characters long.", :max => ArchiveConfig.SUMMARY_MAX)
      
  validates_presence_of :author
  validates_length_of :author, :maximum => AUTHOR_LENGTH_MAX, 
    :too_long=> t('author_too_long', :default => "must be less than %{max} characters long.", :max => AUTHOR_LENGTH_MAX)

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
