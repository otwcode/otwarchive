class Comment < ActiveRecord::Base         
  belongs_to :pseud         
  belongs_to :commentable, :polymorphic => true
 
  validates_presence_of :content
  validates_presence_of :name, :email, :unless => :logged_in? 
  
  def logged_in?
    User.current_user
  end
  
  # Gets methods and associations from acts_as_commentable plugin
  acts_as_commentable  
  has_comment_methods 
end