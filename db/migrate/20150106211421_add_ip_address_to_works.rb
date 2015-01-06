class AddIpAddressToWorks < ActiveRecord::Migration
 def self.up
  add_column :works, :ip_address, :string
 end

 def self.down
  remove_column :works, :ip_address
 end

end
