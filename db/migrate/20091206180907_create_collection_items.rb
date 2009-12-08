class CreateCollectionItems < ActiveRecord::Migration
  def self.up
    create_table :collection_items do |t|
      t.references :collection
      t.references :item, :polymorphic => {:default => 'Work'}
      
      t.integer :user_approval_status, :default => 0, :null => false, :limit => 1
      t.integer :collection_approval_status, :default => 0, :null => false, :limit => 1
      
      t.timestamps
    end
  end

  def self.down
    drop_table :collection_items
  end
end
