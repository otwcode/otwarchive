class Kudo < ActiveRecord::Base
  belongs_to :pseud         
  belongs_to :commentable, :polymorphic => true

  validates_uniqueness_of :pseud_id, 
    :scope => [:commentable_id, :commentable_type], 
    :message => ts("^You have already left kudos here. :)"), 
    :if => "!pseud.nil?"
  
  scope :with_pseud, where("pseud_id IS NOT NULL")
  scope :by_guest, where("pseud_id IS NULL")
end
