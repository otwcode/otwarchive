class AddMetaTags < ActiveRecord::Migration
  def self.up
    create_table :meta_taggings do |t|
      t.integer  :meta_tag_id,  :limit => 8,   :null => false
      t.integer  :sub_tag_id,   :limit => 8,   :null => false
      t.boolean  :direct,       :default => false       
      t.timestamps
    end
  end

  def self.down
    drop_table :meta_taggings
  end
end