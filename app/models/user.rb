class User < ActiveRecord::Base
  # Allows other models to get the current user with User.current_user
  cattr_accessor :current_user
  
  # Acts_as_authentable plugin
  acts_as_authentable
  
  # Authorization plugin
  acts_as_authorized_user
  acts_as_authorizable  
  
  # OpenID plugin
  attr_accessible :identity_url

  has_many :pseuds
  validates_associated :pseuds

  # Retrieve the current default pseud
  def active_pseud
    pseuds.each do |p|
      if p.is_default
        return p
      end
    end
    pseuds.first
  end

end
