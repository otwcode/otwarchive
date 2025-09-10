class Profile < ApplicationRecord
  include Justifiable

  PROFILE_TITLE_MAX = 255
  ABOUT_ME_MAX = 2000

  # Ignore the location and date_of_birth fields until they can be deleted:
  self.ignored_columns = [:location, :date_of_birth]

  belongs_to :user

  validates_length_of :title, allow_blank: true, maximum: PROFILE_TITLE_MAX,
    too_long: ts("must be less than %{max} characters long.", max: PROFILE_TITLE_MAX)
  validates_length_of :about_me, allow_blank: true, maximum: ABOUT_ME_MAX,
    too_long: ts("must be less than %{max} characters long.", max: ABOUT_ME_MAX)
end
