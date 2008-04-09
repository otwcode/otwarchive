class User < ActiveRecord::Base
  acts_as_authentable
  
  # For OpenID
  attr_accessible :identity_url
end
