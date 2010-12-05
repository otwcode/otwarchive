class AddIpAddressToKudos < ActiveRecord::Migration
  def self.up
    add_column :kudos, :ip_address, :string
  end

  def self.down
    remove_column :kudos, :ip_address
  end
end
