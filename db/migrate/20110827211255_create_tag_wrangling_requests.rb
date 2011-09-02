class CreateTagWranglingRequests < ActiveRecord::Migration
  def self.up
    create_table :tag_wrangling_requests do |t|
      t.references :tag
      t.references :owned_tag_set
      t.text :parent_tagname_list
      t.boolean :approved, :default => false, :null => false
      t.boolean :rejected, :default => false, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :tag_wrangling_requests
  end
end
