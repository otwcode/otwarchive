class Preference < ActiveRecord::Base
  belongs_to :user

  validates_format_of :work_title_format, :with => /^[a-zA-Z0-9_\-,\. ]+$/, 
    :message => t('invalid_work_title_format', :default => "can only contain letters, numbers, spaces, and some limited punctuation (comma, period, dash, underscore).")
end
