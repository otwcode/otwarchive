class RemoveMetadataFromChaptersAndWorks < ActiveRecord::Migration
  def self.up
    remove_column :chapters, :metadata_id
    remove_column :works, :metadata_id
  end

  def self.down
    add_column :chapters, :metadata_id, :integer
    add_column :works, :metadata_id, :integer
  end
end
