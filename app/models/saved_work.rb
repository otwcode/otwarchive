class SavedWork < ActiveRecord::Base
  belongs_to :user
  belongs_to :work
  
  validates :user_id, presence: true
  validates :work_id, presence: true, uniqueness: { scope: :user_id }
  
  scope :order_by_updates, joins(:work).order("works.revised_at DESC")
  
  def self.ordered(sort)
    sort == 'updated' ? self.order_by_updates : self.order('created_at DESC')
  end
end
