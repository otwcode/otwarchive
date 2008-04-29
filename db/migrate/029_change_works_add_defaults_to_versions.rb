class ChangeWorksAddDefaultsToVersions < ActiveRecord::Migration
  def self.up
    change_column :works, :major_version, :integer, :default => 0
    change_column :works, :minor_version, :integer, :default => 0
  end

  def self.down
    change_column :works, :minor_version, :integer, :default => nil
    change_column :works, :major_version, :integer, :default => nil
  end
end
