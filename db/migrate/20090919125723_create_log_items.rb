class CreateLogItems < ActiveRecord::Migration
  def self.up
    create_table :log_items do |t|
      t.references :user, :null => false
      t.references :admin
      t.references :role
      t.integer :action, :limit => 1
      t.text :note, :null => false
      t.datetime :enddate

      t.timestamps
    end
    add_index :log_items, :user_id
  end

  def self.down
    drop_table :log_items
    remove_index :log_items, :user_id
  end
end