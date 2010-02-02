class Bookmark < ActiveRecord::Base
  belongs_to :bookmarkable, :polymorphic => true
  belongs_to :pseud
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings, :source => :tagger, :source_type => 'Tag'

  has_many :collection_items, :as => :item, :dependent => :destroy
  has_many :collections, :through => :collection_items

  default_scope :order => "bookmarks.id DESC" # id's stand in for creation date
  
  named_scope :public, :conditions => {:private => false, :hidden_by_admin => false}
  named_scope :not_public, :conditions => {:private => true}
  named_scope :since, lambda { |*args| {:conditions => ["bookmarks.created_at > ?", (args.first || 1.week.ago)]} }
  named_scope :recent, :limit => ArchiveConfig.SEARCH_RESULTS_MAX
  named_scope :recs, :conditions => {:rec => true} #must come before visible in the chain
  
  validates_length_of :notes, 
    :maximum => ArchiveConfig.NOTES_MAX, :too_long => t('notes_too_long', :default => "must be less than {{max}} letters long.", :max => ArchiveConfig.NOTES_MAX)
    
  def self.visible(options = {})
    current_user=User.current_user
    with_scope :find => options do
      find(:all).collect {|b| b if b.visible(current_user)}.compact
    end
  end
    
  def visible(current_user=User.current_user)
    return self if current_user == self.pseud.user
    unless current_user == :false || !current_user
      # Admins should not see private bookmarks
      return self if current_user.is_a?(Admin) && self.private == false
    end
    if !(self.private? || self.hidden_by_admin?)
      if self.bookmarkable.nil? 
        # only show bookmarks for deleted works to the user who 
        # created the bookmark
        return self if pseud.user == current_user
      else
        if self.bookmarkable_type == 'Work' || self.bookmarkable_type == 'Series' || self.bookmarkable_type == 'ExternalWork'
          return self if self.bookmarkable.visible(current_user)
        else
          return self
        end
      end
    end
    return false
  end
  
  # Returns the number of bookmarks on an item visible to the current user
  def self.count_visible_bookmarks(bookmarkable, current_user=:false)
    bookmarkable.bookmarks.visible.length
  end

  # Virtual attribute for external works
  def external=(attributes)   
    unless attributes.values.to_s.blank?
      !self.bookmarkable ? self.bookmarkable = ExternalWork.new(attributes) : self.bookmarkable.attributes = attributes
    end
  end  
  
  # Use existing external work if relevant attributes and tags are the same
  def set_external(id, fandom_string=nil, rating_string=nil, category_string=nil, pairing_string=nil, character_string=nil)
    fetched = ExternalWork.find(id)
    p "LOOK HERE" 
    p fetched.fandom_string
    p fandom_string

    if (fetched.author == self.bookmarkable.author) && (fetched.title == self.bookmarkable.title) && (fetched.summary == self.bookmarkable.summary) && 
      (fetched.fandom_string == fandom_string) && (fetched.rating_string == rating_string) && (fetched.category_string == category_string) && (fetched.pairing_string == pairing_string) && (fetched.character_string == character_string)
      same = true
    else
      same = false
    end
    self.bookmarkable = fetched if same == true
  end
  
  before_save :validate
  # Adds customized error messages for External Work fields
  def validate
    return false if self.bookmarkable_type.blank?
    if self.bookmarkable.class == ExternalWork && (!self.bookmarkable.valid? || self.bookmarkable.fandoms.blank?)
      if self.bookmarkable.fandoms.blank?
        self.bookmarkable.errors.add_to_base("Fandom tag is required")
      end
      self.bookmarkable.errors.full_messages.each { |msg| errors.add_to_base(msg) }
    end
  end
  
  def tag_string
    tags.string
  end
  
  def tag_string=(tag_string)
    self.tags = []
    tag_string.split(ArchiveConfig.DELIMITER_FOR_INPUT).each do |string|
      string.squish!
      tag = Tag.find_by_name(string)
      if tag
        self.tags << tag
      else
        self.tags << Freeform.create(:name => string)
      end
    end
    return self.tags
  end 
end