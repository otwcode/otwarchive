class Metadata < ActiveRecord::Base
  belongs_to :described, :polymorphic => true
  
  TITLE_MAX = 255
  TITLE_MIN = 3
  validates_presence_of :title, :message => "is required.".t
  validates_length_of :title, :within => TITLE_MIN..TITLE_MAX, :message => "must be within #{TITLE_MIN} and #{TITLE_MAX} letters long.".t
 
  SUMMARY_MAX = 1250
  validates_length_of :summary, :maximum => SUMMARY_MAX, :message => "must be less than %d letters long."/SUMMARY_MAX

  NOTES_MAX = 2500
  validates_length_of :notes, :maximum => NOTES_MAX, :message => "must be less than %d letters long."/NOTES_MAX

end
