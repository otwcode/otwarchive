class AddingMoreIndexes < ActiveRecord::Migration
  def self.up
    add_index :comments, [:commentable_id, :commentable_type], :name => :index_comments_commentable
    add_index :creatorships, [:creation_id, :creation_type], :name => :index_creatorships_creation
    add_index :creatorships, [:pseud_id], :name => :index_creatorships_pseud
    add_index :users, :login
    add_index :pseuds, [:user_id, :name]
  end

  def self.down
    remove_index :comments, :name => :index_comments_commentable
    remove_index :creatorships, :name => :index_creatorships_creation
    remove_index :creatorships, :name => :index_creatorships_pseud
    remove_index :users, :login
    remove_index :pseuds, :column => [:user_id, :name]
  end
end
