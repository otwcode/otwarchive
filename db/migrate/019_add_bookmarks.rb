class AddBookmarks < ActiveRecord::Migration
  def self.up
    create_table :bookmarks, :force => true do |t|
      t.column :title, :string, :limit => 50, :default => ""
      t.column :created_at, :datetime, :null => false
      t.column :bookmarkable_type, :string,
        :limit => 15, :default => "", :null => false
      t.column :bookmarkable_id, :integer, :default => 0, :null => false
      t.column :user_id, :integer, :default => 0, :null => false
    end
  
    add_index :bookmarks, ["user_id"], :name => "fk_bookmarks_user"
  end
  
  def self.down
    drop_table :bookmarks
  end
end