class AddMajorVersionMinorVersionToWorks < ActiveRecord::Migration
  def self.up
    add_column :works, :major_version, :integer
    add_column :works, :minor_version, :integer
  end

  def self.down
    remove_column :works, :minor_version
    remove_column :works, :major_version
  end
end
