# Class which holds feedback sent to the archive administrators about the archive as a whole
class Feedback < ActiveRecord::Base
  # note -- this has NOTHING to do with the Comment class!
  # This is just the name of the text field in the Feedback
  # class which holds the user's comments. 
  validates_presence_of :comment
end
