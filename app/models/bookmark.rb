class Bookmark < ActiveRecord::Base
  belongs_to :bookmarkable, :polymorphic => true
  belongs_to :user
  has_many :taggings, :as => :taggable, :dependent => :destroy
  include TaggingExtensions

  NOTES_MAX = 4300
  validates_length_of :notes, :maximum => NOTES_MAX, :message => "must be less than %d letters long."/NOTES_MAX
    
  def public?
    !self.private?
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
    %w(title summary notes).each {|a| same = false unless self.bookmarkable.metadata[a.to_sym] == fetched.metadata[a.to_sym]}
    self.bookmarkable = fetched if same  
  end
  
  # Adds customized error messages and clears the "chapters is invalid" message for invalid chapters
  def validate
    if self.bookmarkable.class == ExternalWork && !self.bookmarkable.valid?
      self.bookmarkable.errors.full_messages.each { |msg| errors.add_to_base(msg) }
    end
  end
  
end
