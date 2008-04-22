class EmailTimeout < ActiveRecord::Base
  
  set_table_name :emails
  validates_email_veracity_of :address, :timeout => 0.0001
  
end