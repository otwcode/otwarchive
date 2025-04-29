class AddResentAtToInvitations < ActiveRecord::Migration[6.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    add_column :invitations, :resent_at, :datetime
  end
end
