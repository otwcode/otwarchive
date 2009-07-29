class Bookmark < ActiveRecord::Base
  belongs_to :bookmarkable, :polymorphic => true
  belongs_to :pseud
  has_many :taggings, :as => :taggable
  has_many :tags, :through => :taggings, :source => :tagger, :source_type => 'Tag'
  
  named_scope :public, :conditions => {:private => false}
  named_scope :recent, lambda { |*args| {:conditions => ["bookmarks.created_at > ?", (args.first || 4.weeks.ago)]} }
  
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
        if self.bookmarkable_type == 'Work'
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
  
  # Use existing external work if relevant attributes are the same
  def set_external(id)
    fetched = ExternalWork.find(id)
    same = fetched.author == self.bookmarkable.author ? true : false
    %w(title summary notes).each {|a| same = false unless self.bookmarkable[a.to_sym] == fetched[a.to_sym]}
    self.bookmarkable = fetched if same  
  end
  
  # Adds customized error messages for External Work fields
  def validate
    return false if self.bookmarkable_type.blank?
    if self.bookmarkable.class == ExternalWork && !self.bookmarkable.valid?
      self.bookmarkable.errors.full_messages.each { |msg| errors.add_to_base(msg) }
    end
  end
  
  def tag_string
    tags.string
  end
  
  def tag_string=(tag_string)
    self.tags = []
    tag_string.split(ArchiveConfig.DELIMITER).each do |string|
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