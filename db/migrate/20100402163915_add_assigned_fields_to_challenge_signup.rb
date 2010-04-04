class AddAssignedFieldsToChallengeSignup < ActiveRecord::Migration
  def self.up
    add_column :challenge_signups, :assigned_as_request, :boolean, :null => :false, :default => false
    add_column :challenge_signups, :assigned_as_offer, :boolean, :null => :false, :default => false
  end

  def self.down
    remove_column :challenge_signups, :assigned_as_offer
    remove_column :challenge_signups, :assigned_as_request
  end
end
