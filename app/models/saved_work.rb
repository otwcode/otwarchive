class SavedWork < ActiveRecord::Base
  belongs_to :user
  belongs_to :work
  
  validates :user_id, presence: true
  validates :work_id, presence: true, uniqueness: { scope: :user_id }
  
  def works_for_user(user)
    Work.joins(:saved_works).where(user_id: user.id).order('created_at DESC')
  end
end
