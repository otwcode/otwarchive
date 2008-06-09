class AddPrivacyOptionToWorks < ActiveRecord::Migration
  def self.up
    add_column :works, :restricted, :boolean
  end

  def self.down
    add_column :works, :restricted
  end
end
