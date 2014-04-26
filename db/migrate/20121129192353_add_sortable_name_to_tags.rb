class AddSortableNameToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :sortable_name, :string, :null => false, :default => ''
    add_index :tags, :sortable_name
  end

  def self.down
    remove_column :tags, :sortable_name
  end
end
