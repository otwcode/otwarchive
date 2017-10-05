class FannishNextOfKin < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :kin_id, presence: true
  validates :kin_email, presence: true

  def kin_name
    User.find_by(id: kin_id).try(:login)
  end
end
