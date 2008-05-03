class AddPreferencesToExisting < ActiveRecord::Migration
  def self.up
    change_column :preferences, :history_enabled, :boolean, :default => true
    change_column :preferences, :email_visible, :boolean, :default => false

    User.find(:all).each do |user|
      user.preference = Preference.new(:history_enabled => true, :email_visible => false)
      user.save!
    end
  end

  def self.down
    change_column :preferences, :history_enabled, :boolean, :default => nil
    change_column :preferences, :email_visible, :boolean, :default => nil
  end
end
