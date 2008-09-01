class AddTitleToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :title, :string
  end

  def self.down
    remove_column :profiles, :title
  end
end
