# Class which holds feedback sent to the archive administrators about the archive as a whole
class Feedback < ActiveRecord::Base
  # note -- this has NOTHING to do with the Comment class!
  # This is just the name of the text field in the Feedback
  # class which holds the user's comments. 
  validates_presence_of :comment
  validates_email_veracity_of :email, :allow_blank => true, 
    :message => t('invalid_email', :default => 'address appears to be invalid. Please use a different address or leave blank.') 
end
