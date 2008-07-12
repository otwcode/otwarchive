class AddLatAndLongToAddress < ActiveRecord::Migration
  def self.up
    add_column :addresses, :lat, :float
    add_column :addresses, :long, :float
  end

  def self.down
    remove_column :addresses, :lat
    remove_column :addresses, :long
  end
end
