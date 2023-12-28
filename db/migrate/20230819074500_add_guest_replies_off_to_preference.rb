class AddGuestRepliesOffToPreference < ActiveRecord::Migration[6.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    add_column :preferences, :guest_replies_off, :boolean, default: false, null: false
  end
end
