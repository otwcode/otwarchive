class AddAdult < ActiveRecord::Migration
  def self.up
    add_column :works, :adult, :boolean, :default => 0
    add_column :preferences, :adult, :boolean, :default => 0
    add_column :tags, :adult, :boolean, :default => 0
  end

  def self.down
    remove_column :works, :adult
    remove_column :tags, :adult
    remove_column :preferences, :adult
  end
end
