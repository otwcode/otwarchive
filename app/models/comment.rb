class Comment < ActiveRecord::Base         
  belongs_to :pseud         
  belongs_to :commentable, :polymorphic => true
 
  validates_presence_of :content
  validates_presence_of :name, :email, :unless => :logged_in? 
  before_create :check_for_spam
  
  def logged_in?
    User.current_user
  end
  
  # Gets methods and associations from acts_as_commentable plugin
  acts_as_commentable  
  has_comment_methods 
  
  
  def akismet_attributes
    {
      :key => ArchiveConfig.askimet_key,
      :blog => ArchiveConfig.askimet_name,
      :user_ip => ip_address,
      :user_agent => user_agent,
      :comment_author => name,
      :comment_author_email => email,
      :comment_content => content
    }
  end
  
  def check_for_spam
    #don't check for spam if the comment is 'signed'
    self.approved = self.pseud_id || !Akismetor.spam?(akismet_attributes)
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