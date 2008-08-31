class Comment < ActiveRecord::Base         
  belongs_to :pseud         
  belongs_to :commentable, :polymorphic => true
  has_many :users, :through => :inbox_comments
 
  validates_presence_of :name, :email, :unless => :pseud_id
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :on => :create, :unless => :pseud_id
  #validates_email_veracity_of :email, 
  #  :message => 'This does not seem to be a valid email address.'.t, 
  #  :timeout => 0.5

  validates_presence_of :content
  validates_length_of :content, 
    :maximum => ArchiveConfig.COMMENT_MAX, 
    :too_long => "must be less than %d letters long."/ArchiveConfig.COMMENT_MAX

  before_create :check_for_spam
  
  # Gets methods and associations from acts_as_commentable plugin
  acts_as_commentable  
  has_comment_methods 
  
  
  def akismet_attributes
    {
      :key => ArchiveConfig.AKISMET_KEY,
      :blog => ArchiveConfig.AKISMET_NAME,
      :user_ip => ip_address,
      :user_agent => user_agent,
      :comment_author => name,
      :comment_author_email => email,
      :comment_content => content
    }
  end
  
  def check_for_spam
    #don't check for spam if the comment is 'signed'
    self.approved = !self.pseud_id.nil? || !Akismetor.spam?(akismet_attributes)
    true # return true so it doesn't stop save
  end
  
  #don't want to submit anything to Akismet while testing. bad things might happen
  def mark_as_spam!
    update_attribute(:approved, false)
    #Akismetor.submit_spam(akismet_attributes)
  end

  def mark_as_ham!
    update_attribute(:approved, true)
    #Akismetor.submit_ham(akismet_attributes)
  end
end
