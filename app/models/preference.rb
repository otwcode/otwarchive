class Preference < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :user
  belongs_to :skin

  validates_format_of :work_title_format, with: /^[a-zA-Z0-9_\-,\. ]+$/,
    message: ts("can only contain letters, numbers, spaces, and some limited punctuation (comma, period, dash, underscore)."),
    multiline: true

  before_create :set_default_skin
  def set_default_skin
    self.skin = Skin.default
  end

  def self.disable_work_skin?(param)
     return false if param == 'creator'
     return true if param == 'light' || param == 'disable'
     return false unless User.current_user.is_a? User
     return User.current_user.try(:preference).try(:disable_work_skins)
  end

  def hide_hit_counts
    self.try(:hide_all_hit_counts) || self.try(:hide_private_hit_count)
  end
end
