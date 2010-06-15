class Bookmark < ActiveRecord::Base
  belongs_to :bookmarkable, :polymorphic => true
  belongs_to :pseud
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings, :source => :tagger, :source_type => 'Tag'

  has_many :collection_items, :as => :item, :dependent => :destroy
  has_many :collections, :through => :collection_items

  validates_length_of :notes, 
    :maximum => ArchiveConfig.NOTES_MAX, :too_long => t('notes_too_long', :default => "must be less than {{max}} letters long.", :max => ArchiveConfig.NOTES_MAX)

  default_scope :order => "bookmarks.id DESC" # id's stand in for creation date
  
  named_scope :public, :conditions => {:private => false, :hidden_by_admin => false}
  named_scope :not_public, :conditions => {:private => true}
  named_scope :since, lambda { |*args| {:conditions => ["bookmarks.created_at > ?", (args.first || 1.week.ago)]} }
  named_scope :recent, :limit => ArchiveConfig.SEARCH_RESULTS_MAX
  named_scope :recs, :conditions => {:rec => true} #must come before visible in the chain
  
  named_scope :in_collection, lambda {|collection|
    {
      :select => "DISTINCT bookmarks.*",
      :joins => "INNER JOIN collection_items ON (collection_items.item_id = works.id AND collection_items.item_type = 'Bookmark')
                 INNER JOIN collections ON collection_items.collection_id = collections.id",
      :conditions => ['collections.id IN (?) AND collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?', 
                   [collection.id] + collection.children.collect(&:id), CollectionItem::APPROVED, CollectionItem::APPROVED]
    }
  }

   named_scope :visible_to_public, {
   	:joins => "LEFT JOIN works ON (bookmarks.bookmarkable_id = works.id AND bookmarks.bookmarkable_type = 'Work')",
   	:conditions => "private = 0 AND bookmarks.hidden_by_admin = 0 AND works.restricted != 1 AND works.hidden_by_admin != 1"
  }
  
   named_scope :visible_logged_in, {
   	:joins => "LEFT JOIN works ON (bookmarks.bookmarkable_id = works.id AND bookmarks.bookmarkable_type = 'Work')",
   	:conditions => "private = 0 AND bookmarks.hidden_by_admin = 0 AND works.hidden_by_admin != 1"
  }
      
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
  
  # Adds customized error messages for External Work fields
  def validate_on_create
    return false if self.bookmarkable_type.blank?
    if self.bookmarkable.class == ExternalWork && (!self.bookmarkable.valid? || self.bookmarkable.fandoms.blank?)
      if self.bookmarkable.fandoms.blank?
        self.bookmarkable.errors.add_to_base("Fandom tag is required")
      end
      self.bookmarkable.errors.full_messages.each { |msg| errors.add_to_base(msg) }
    end
  end
  
  def tag_string
    tags.map{|tag| tag.name}.join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
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

  def self.search_with_sphinx(query, page)
    search_string, with_hash, query_errors = Query.split_query(query)
    # set pagination and extend mode
    options = {
      :per_page => ArchiveConfig.ITEMS_PER_PAGE, 
      :max_matches => ArchiveConfig.SEARCH_RESULTS_MAX, 
      :page => page, 
      :match_mode => :extended 
      }
    # attribute restrictions
    with_hash.update({:private => false, :hidden_by_admin => false})
    options[:with] = with_hash
    return query_errors, Bookmark.search(search_string, options)
  end

  # Index for Thinking Sphinx
  define_index do

    # fields
    indexes bookmarkable_type, :as => 'type'
    indexes notes

    # associations
    indexes pseud(:name), :as => 'bookmarker'
    indexes tags(:name), :as => 'tag'
    indexes bookmarkable.tags(:name), :as => 'indirect'
        
    # attributes
    has rec, updated_at, bookmarkable_id
    has private, hidden_by_admin

    # properties
    set_property :delta => :delayed
  end
  
  
end
