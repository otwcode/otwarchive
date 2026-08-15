# Allows admins to track all past emails of a user
class UserPastEmail < ApplicationRecord
  belongs_to :user
end
