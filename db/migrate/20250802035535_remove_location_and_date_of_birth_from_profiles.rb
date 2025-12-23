class RemoveLocationAndDateOfBirthFromProfiles < ActiveRecord::Migration[7.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    remove_column :profiles, :location, :string
    remove_column :profiles, :date_of_birth, :date
  end
end
