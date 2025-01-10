class Preference < ApplicationRecord
  belongs_to :user
  belongs_to :skin
  belongs_to :locale, foreign_key: "preferred_locale"

  validates :work_title_format,
            format: {
              with: /\A[a-zA-Z0-9_\-,\. ]+\z/,
              message: ts("can only contain letters, numbers, spaces, and some limited punctuation (comma, period, dash, underscore).")
            }

  validate :can_use_skin, if: :skin_id_changed?

  before_create :set_default_skin
  def set_default_skin
    self.skin_id = AdminSetting.current.default_skin_id
  end

  def self.disable_work_skin?(param)
    return false if param == "creator"
    return true if %w[light disable].include?(param)
    return false unless User.current_user.is_a?(User)

    User.current_user.try(:preference).try(:disable_work_skins)
  end

  def can_use_skin
    return if skin_id == AdminSetting.default_skin_id ||
              (skin.is_a?(Skin) && skin.approved_or_owned_by?(user))

    errors.add(:base, "You don't have permission to use that skin!")
  end

  def locale
    $rollout.active?(:set_locale_preference, user) ? super : Locale.default
  end
end
