class CreateCollectionPreferences < ActiveRecord::Migration
  def self.up
    create_table :collection_preferences do |t|
      t.references :collection
      t.integer :allowed_to_post, :default => 1, :null => false, :limit => 1

      t.timestamps
    end
  end

  def self.down
    drop_table :collection_preferences
  end
end
