class Admin < ActiveRecord::Base
  acts_as_authentable(false)
  
  #hacks to allow admin objects to be created in tests and the console
  #without adding database columns that should not be used
  def identity_url
    return nil   #can't log in as admin with openid
  end
  def activation_code=(code)
    return code  #admin objects are created manually, they don't need a code
  end
  def activated_at=(time)
    return time  #not needed since activated at creation
  end
end
