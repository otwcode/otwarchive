class Profile < ActiveRecord::Base
  
  PROFILE_TITLE_MAX = 255
  LOCATION_MAX = 255
  ABOUT_ME_MAX = 2000
  
  belongs_to :user
  
  validates_length_of :location, :allow_blank => true, :maximum => LOCATION_MAX, 
    :too_long => t('location_too_long', :default => "must be less than {{max}} characters long.", :max => LOCATION_MAX)
  validates_length_of :title, :allow_blank => true, :maximum => PROFILE_TITLE_MAX, 
    :too_long => t('title_too_long', :default => "must be less than {{max}} characters long.", :max => PROFILE_TITLE_MAX)
  validates_length_of :about_me, :allow_blank => true, :maximum => ABOUT_ME_MAX, 
    :too_long => t('about_me_too_long', :default => "must be less than {{max}} characters long.", :max => ABOUT_ME_MAX)

end
