class Preference < ActiveRecord::Base
  belongs_to :user
  belongs_to :skin

  validates_format_of :work_title_format, with: /^[a-zA-Z0-9_\-,\. ]+$/,
    message: ts("can only contain letters, numbers, spaces, and some limited punctuation (comma, period, dash, underscore).")

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

  #FIXME hack because time zones are being html encoded. couldn't figure out why.
  before_save :fix_time_zone
  def fix_time_zone
    return true if self.time_zone.nil?
    return true if ActiveSupport::TimeZone[self.time_zone]
    try = self.time_zone.gsub('&amp;', '&')
    self.time_zone = try if ActiveSupport::TimeZone[try]
  end

  def hide_hit_counts
    self.try(:hide_all_hit_counts) || self.try(:hide_private_hit_count)
  end
end
