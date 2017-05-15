class RolesUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :role

  self.primary_key = [:user_id, :role_id]
end
