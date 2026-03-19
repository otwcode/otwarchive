# Allows admins to track all past usernames of a user
class ImportedUrl < ApplicationRecord
  belongs_to :work
end
