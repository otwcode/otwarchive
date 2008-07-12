class AddCapitalizationToSeller < ActiveRecord::Migration
  def self.up
    add_column :sellers, :capitalization, :float, :default => 0.0
  end

  def self.down
    remove_column :sellers, :capitalization
  end
end
