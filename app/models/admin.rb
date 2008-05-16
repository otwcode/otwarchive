class Admin < ActiveRecord::Base
  acts_as_authentable(false)
  
  #hacks to allow admin objects to be created in tests and the console
  #without adding database columns that should not be used
  def identity_url
    return nil   #can't log in as admin with openid
  end
end
