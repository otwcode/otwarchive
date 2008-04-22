class EmailSkipRemote < ActiveRecord::Base
  
  set_table_name :emails
  validates_email_veracity_of :address, :domain_check => false
  
end