class FannishNextOfKin < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :kin_id, presence: true
  validates :kin_email, presence: true

  def kin_name
    User.find_by(id: kin_id).try(:login)
  end

  def self.update_for_user(user, kin_name, kin_email)
    kin_user = User.find_by(login: kin_name)
    current_fnok = user.fannish_next_of_kin
    # first scenario: user has no existing FNOK
    if current_fnok.nil?
      return unless kin_user.present? && kin_email.present?
      create(
        user_id: user.id,
        kin_id: kin_user.id,
        kin_email: kin_email
      )
    # second scenario: update user's FNOK
    elsif kin_user.present? && kin_email.present?
      current_fnok.update(
        kin_id: kin_user.id,
        kin_email: kin_email
      )
    # third scenario: delete user's FNOK
    elsif kin_name.blank? && kin_email.blank?
      current_fnok.destroy
    end
  end
end
