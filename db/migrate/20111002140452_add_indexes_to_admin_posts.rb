class AddIndexesToAdminPosts < ActiveRecord::Migration
  def self.up
    add_index "admin_posts", ["created_at"]
  end

  def self.down
    remove_index "admin_posts", ["created_at"]
  end
end
