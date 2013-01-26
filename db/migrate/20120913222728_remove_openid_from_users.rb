class RemoveOpenidFromUsers < ActiveRecord::Migration
  def self.up
    remove_index :users, :identity_url
    remove_column :users, :identity_url
  end

  def self.down
    add_column :users, :identity_url, :text, :limit => 191
    add_index :users, :identity_url, :unique => true
  end
end
