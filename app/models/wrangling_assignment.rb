class WranglingAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :fandom
  
  validates_uniqueness_of :user_id, scope: :fandom_id
  validates_presence_of :user_id
  validates_presence_of :fandom_id
  validate :canonicity
  def canonicity
    unless Tag.find_by(id: fandom_id, canonical: true)
      errors.add(:base, ts("Sorry, only canonical fandoms can be assigned to wranglers."))
    end
  end
  
end
