class User < ActiveRecord::Base
  # Allows other models to get the current user with User.current_user
  cattr_accessor :current_user
  attr_accessor :translation_mode_active
  
  # Acts_as_authentable plugin
  acts_as_authentable
  
  # Authorization plugin
  acts_as_authorized_user
  acts_as_authorizable  
  
  # OpenID plugin
  attr_accessible :identity_url
  
  has_many :pseuds
  validates_associated :pseuds
  
  has_one :profile
  validates_associated :profile
  
  validates_email_veracity_of :email, :message => 'does not seem to be a valid email address.'
  # validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
  # validates_format_of :password, :with => /(?=.*\d)(?=.*([a-z]|[A-Z]))/, :message => 'must have at least one digit and one alphabet character.'
  
  # Retrieve the current default pseud
  def default_pseud
    pseuds.each do |p|
      if p.is_default
        return p
      end
    end
    pseuds.first
  end
  
  # fetch all pseuds belong to a user
  def creations
    pseuds.collect do |pseud| 
      unless pseud.creations.nil?
        pseud.creations.entries
      end
    end
  end
  
end
