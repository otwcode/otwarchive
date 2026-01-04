# Allows admins to track all past emails of a user
class UserPastEmails < ApplicationRecord
  belongs_to :user
end
