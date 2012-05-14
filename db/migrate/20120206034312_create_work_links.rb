class CreateWorkLinks < ActiveRecord::Migration
  def self.up
    create_table :work_links do |t|
      t.references :work
      t.string :url
      t.integer :count

      t.timestamps
    end
    
    add_index "work_links", ["work_id", "url"], :name => "work_links_work_id_url", :unique => true
    
  end

  def self.down
    drop_table :work_links
  end
end
