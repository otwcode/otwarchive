class AddInheritedToFilterTaggings < ActiveRecord::Migration
  def self.up
    add_column :filter_taggings, :inherited, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :filter_taggings, :inherited
  end
end
