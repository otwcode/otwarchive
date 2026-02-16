# Allows admins to track all past usernames of a user
class UserPastUsername < ApplicationRecord
  belongs_to :user
end
