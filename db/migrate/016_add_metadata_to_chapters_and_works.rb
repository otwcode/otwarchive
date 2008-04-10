class AddMetadataToChaptersAndWorks < ActiveRecord::Migration
  def self.up
    add_column :chapters, :metadata_id, :integer
    add_column :works, :metadata_id, :integer
  end

  def self.down
    remove_column :chapters, :metadata_id
    remove_column :works, :metadata_id
  end
end
