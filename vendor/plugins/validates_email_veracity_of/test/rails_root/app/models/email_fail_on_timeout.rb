class EmailFailOnTimeout < ActiveRecord::Base
  
  set_table_name :emails
  validates_email_veracity_of :address, :fail_on_timeout => true, :timeout => 0.0001
  
end