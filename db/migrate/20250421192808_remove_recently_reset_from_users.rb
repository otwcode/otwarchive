class RemoveRecentlyResetFromUsers < ActiveRecord::Migration[7.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    remove_column :users, :recently_reset, :boolean
  end
end
