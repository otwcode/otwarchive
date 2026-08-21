class AddDeviseTwoFactorToUsers < ActiveRecord::Migration[8.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    change_table :users, bulk: true do |t|
      t.column :otp_secret, :string
      t.column :consumed_timestep, :integer
      t.column :otp_required_for_login, :boolean
      t.column :otp_backup_codes, :text
    end
  end
end
