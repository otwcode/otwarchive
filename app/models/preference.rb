class Preference < ActiveRecord::Base
  belongs_to :user
  belongs_to :skin


  validates_format_of :work_title_format, :with => /^[a-zA-Z0-9_\-,\. ]+$/,
    :message => t('invalid_work_title_format', :default => "can only contain letters, numbers, spaces, and some limited punctuation (comma, period, dash, underscore).")

  def before_create
    self.skin = Skin.default
  end

  def self.light?(param)
     return false if param == 'creator'
     return true if param == 'light'
     return false unless User.current_user.is_a? User
     return User.current_user.try(:preference).try(:disable_ugs)
  end


end
