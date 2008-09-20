class MakeIdentityUrlUniq < ActiveRecord::Migration
  def self.up
    add_index :users, [:identity_url], :name => :index_users_on_identity_url, :unique => true
  end

  def self.down
    remove_index :users, :name => :index_users_on_identity_url
  end
end
