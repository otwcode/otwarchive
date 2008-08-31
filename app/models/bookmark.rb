class Bookmark < ActiveRecord::Base
  belongs_to :bookmarkable, :polymorphic => true
  belongs_to :user
  has_many :taggings, :as => :taggable, :dependent => :destroy
  include TaggingExtensions

  validates_length_of :notes, 
    :maximum => ArchiveConfig.NOTES_MAX, :too_long => "must be less than %d letters long."/ArchiveConfig.NOTES_MAX
    
  def self.visible(current_user=:false, options = {})
    with_scope :find => options do
      find(:all).collect {|b| b if b.visible(current_user)}.compact
    end
  end
  
  def visible(current_user=:false)
    visibility = (user == current_user || !(self.private? || self.hidden_by_admin?))
    if visibility
      if self.bookmarkable_type == 'Work'
        return self if self.bookmarkable.visible(current_user)
      else
        return self
      end
    end
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
  
end
