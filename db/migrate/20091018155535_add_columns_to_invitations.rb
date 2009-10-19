class AddColumnsToInvitations < ActiveRecord::Migration
  def self.up   
    rename_column :invitations, :recipient_email, :invitee_email
    rename_column :invitations, :external_author_id, :invitee_id
    add_column :invitations, :invitee_type, :string
    rename_column :invitations, :sender_id, :creator_id
    add_column :invitations, :creator_type, :string
    add_column :invitations, :redeemed_at, :datetime
    add_column :invitations, :from_queue, :boolean, :default => false, :null => false   
  end

  def self.down
    rename_column :invitations, :invitee_email, :recipient_email
    rename_column :invitations, :invitee_id, :external_author_id
    remove_column :invitations, :invitee_type
    rename_column :invitations, :creator_id, :sender_id
    remove_column :invitations, :creator_type
    remove_column :invitations, :redeemed_at
    remove_column :invitations, :from_queue     
  end
end
