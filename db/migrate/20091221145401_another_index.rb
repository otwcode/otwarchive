class AnotherIndex < ActiveRecord::Migration
  def self.up
    add_index :tags, :merger_id
    add_index :chapters, :work_id
  end

  def self.down
    remove_index :tags, :merger_id
    remove_index :chapters, :work_id
  end
end
