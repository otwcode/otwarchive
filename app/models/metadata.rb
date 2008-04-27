class Metadata < ActiveRecord::Base
  belongs_to :described, :polymorphic => true
  
  TITLE_MAX = 255
  TITLE_MIN = 3
  validates_presence_of :title
  validates_length_of :title, :within => TITLE_MIN..TITLE_MAX
 
  SUMMARY_MAX = 1000
  validates_length_of :summary, :maximum => SUMMARY_MAX

  NOTES_MAX = 1000
  validates_length_of :notes, :maximum => NOTES_MAX

end
