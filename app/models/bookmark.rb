class Bookmark < ActiveRecord::Base
  belongs_to :bookmarkable, :polymorphic => true
  belongs_to :user
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings

  validates_length_of :notes, 
    :maximum => ArchiveConfig.NOTES_MAX, :too_long => "must be less than %d letters long."/ArchiveConfig.NOTES_MAX #/comment here just to fix aptana coloring
    
  def self.visible(options = {})
    current_user=User.current_user
    with_scope :find => options do
      find(:all).collect {|b| b if b.visible(current_user)}.compact
    end
  end
    
  def visible(current_user=User.current_user)
    return self if current_user == self.user
    unless current_user == :false || !current_user
      return self if current_user.is_admin?
    end
    if !(self.private? || self.hidden_by_admin?)
      if self.bookmarkable.nil? 
        # only show bookmarks for deleted works to the user who 
        # created the bookmark
        return self if user == current_user
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

  ################################################################################
  # TAGGING
  # Bookmarks are taggable objects. They don't care about type, however.
  ################################################################################
  def remove_tag(tag)
    tagging = Tagging.find_by_tag_id_and_taggable_id(tag.id, self.id)
    tagging.destroy if tagging
  end
  def replace_tags(new_tags=[])
    return false if self.new_record?                    # can't create an association if not saved
    new_tags.each do |tag|
      return false unless tag.is_a?(Tag)                # not a tag
      return false if tag.new_record?                    # can't create an association if not saved
    end  
    # if haven't returned, all the tags are okay
    old_tags = self.tags.find_all_by_type(type)
    (new_tags - old_tags).each {|t| self.tags << t}
    (old_tags - new_tags).each {|t| self.remove_tag(t) }
  end

  def tag_string
    self.tags.valid.map(&:name).sort.join(ArchiveConfig.DELIMITER)
  end
  
  def tag_string=(tag_string)
     self.replace_tags(tag_string.split(ArchiveConfig.DELIMITER).each {|string| Tag.find_or_create_by_name(string)})
  end
end
