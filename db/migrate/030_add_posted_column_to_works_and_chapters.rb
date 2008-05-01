class AddPostedColumnToWorksAndChapters < ActiveRecord::Migration
  def self.up
    add_column :works, :posted, :boolean
    add_column :chapters, :posted, :boolean
  end

  def self.down
    remove_column :works, :posted
    remove_column :chapters, :posted
  end
end