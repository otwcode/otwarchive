class AddIpAddressToWorks < ActiveRecord::Migration
 def self.up
  add_column :works, :ip_address, :string
  add_index "works", "ip_address"
 end

 def self.down
  remove_index "works", "ip_address"
  remove_column :works, :ip_address
 end

end
