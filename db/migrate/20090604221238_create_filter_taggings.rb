class CreateFilterTaggings < ActiveRecord::Migration
  def self.up
    create_table :filter_taggings do |t|
      t.integer  :filter_id,       :limit => 8,   :null => false
      t.integer  :filterable_id,   :limit => 8,   :null => false
      t.string   :filterable_type, :limit => 100
      
      t.timestamps
    end
    add_index :filter_taggings, [:filterable_id, :filterable_type], :name => :index_filter_taggings_filterable    
  end

  def self.down
    remove_index :filter_taggings, :name => :index_filter_taggings_filterable
    drop_table :filter_taggings
  end
end
