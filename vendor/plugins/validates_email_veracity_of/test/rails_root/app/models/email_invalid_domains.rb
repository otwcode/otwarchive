class EmailInvalidDomains < ActiveRecord::Base
  
  set_table_name :emails
  validates_email_veracity_of :address, :invalid_domains => %w[invalid.com invalid.ca surely-not-valid.net]
  
end