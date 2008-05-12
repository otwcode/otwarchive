class AddDateOfBirthVisibleToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :date_of_birth_visible, :boolean, :default => false
  end

  def self.down
    remove_column :preferences, :date_of_birth_visible
  end
end
