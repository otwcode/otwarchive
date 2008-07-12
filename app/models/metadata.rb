class Metadata < ActiveRecord::Base
  belongs_to :described, :polymorphic => true
  is_indexed :fields => ['title', 'summary', 'notes']
  
  TITLE_MAX = 255
  TITLE_MIN = 3
  validates_presence_of :title, :message => "is required.".t, :if => :is_work?
  validates_length_of :title, :within => TITLE_MIN..TITLE_MAX, :message => "must be within #{TITLE_MIN} and #{TITLE_MAX} letters long.".t, :if => :is_work?
  validates_length_of :title, :maximum => TITLE_MAX, :message => "must be less than %d letters long."/TITLE_MAX
 
  SUMMARY_MAX = 1250
  validates_length_of :summary, :maximum => SUMMARY_MAX, :message => "must be less than %d letters long."/SUMMARY_MAX

  NOTES_MAX = 2500
  validates_length_of :notes, :maximum => NOTES_MAX, :message => "must be less than %d letters long."/NOTES_MAX
  
  # Skips title validation for chapters
  def is_work?
    self.described_type == "Work"
  end

end
