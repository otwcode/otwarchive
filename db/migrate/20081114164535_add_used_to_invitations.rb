class AddUsedToInvitations < ActiveRecord::Migration
  def self.up
    ThinkingSphinx.deltas_enabled=false

    add_column :invitations, :used, :boolean, :default => false, :null => false
    
    Invitation.reset_column_information
    Invitation.find(:all).each do |invitation|
      unless invitation.recipient.nil? 
        invitation.used = true
        invitation.save
      end
    end

    ThinkingSphinx.deltas_enabled=true    
  end

  def self.down
    remove_column :invitations, :used
  end
end
