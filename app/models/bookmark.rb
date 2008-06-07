class Bookmark < ActiveRecord::Base
  belongs_to :bookmarkable, :polymorphic => true
  belongs_to :user

  NOTES_MAX = 4300
  validates_length_of :notes, :maximum => NOTES_MAX, :message => "must be less than %d letters long."/NOTES_MAX
  
  def public?
    !self.private?
  end
end
