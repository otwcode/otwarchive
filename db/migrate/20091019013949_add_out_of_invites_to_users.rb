class AddOutOfInvitesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :out_of_invites, :boolean, :default => true, :null => false
    remove_column :users, :invitation_limit
  end

  def self.down
    remove_column :users, :out_of_invites
    add_column :users, :invitation_limit, :limit => 8, :default => 1
  end
end
