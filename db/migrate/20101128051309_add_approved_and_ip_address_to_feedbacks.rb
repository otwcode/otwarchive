class AddApprovedAndIpAddressToFeedbacks < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :approved, :boolean, :default => false, :null => false
    add_column :feedbacks, :ip_address, :string
  end

  def self.down
    remove_column :feedbacks, :approved
    remove_column :feedbacks, :ip_address
  end
end
