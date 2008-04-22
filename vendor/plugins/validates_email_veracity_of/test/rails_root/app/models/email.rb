class Email < ActiveRecord::Base
  
  validates_email_veracity_of :address
  
end