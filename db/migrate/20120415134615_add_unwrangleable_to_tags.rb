class AddUnwrangleableToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :unwrangleable, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :tags, :unwrangleable
  end
end
