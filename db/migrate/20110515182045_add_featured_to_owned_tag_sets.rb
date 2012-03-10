class AddFeaturedToOwnedTagSets < ActiveRecord::Migration
  def self.up
    add_column :owned_tag_sets, :featured, :boolean, :default => false, :null => false
    add_column :owned_tag_sets, :description_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
  end

  def self.down
    remove_column :owned_tag_sets, :featured
    remove_column :owned_tag_sets, :description_sanitizer_version
  end
end
