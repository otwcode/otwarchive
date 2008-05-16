class AddProfilesForExistingUsers < ActiveRecord::Migration
  def self.up
    User.find(:all).each do |user|
      if user.profile.nil?
        user.profile = Profile.new()
        user.save!
      end
    end
  end

  def self.down
  end
end
