class User < ActiveRecord::Base
  acts_as_authentable
  has_many :pseuds
  
  # For OpenID
  attr_accessible :identity_url
end
