class CreateWranglingGuidelines < ActiveRecord::Migration
  def up
    create_table :wrangling_guidelines do |t|
      t.integer :admin_id
      t.string :title
      t.text :content
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :position
      t.integer :content_sanitizer_version, :limit => 2, :default => 0, :null => false
    end
  end

  def down
    drop_table :wrangling_guidelines    
  end
end
