class AddIndexToInvitations < ActiveRecord::Migration[6.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    add_index :invitations, :invitee_email
  end
end
