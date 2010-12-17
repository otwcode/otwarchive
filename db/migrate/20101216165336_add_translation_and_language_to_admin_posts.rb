class AddTranslationAndLanguageToAdminPosts < ActiveRecord::Migration
  def self.up
    add_column :admin_posts, :translated_post_id, :integer
    add_column :admin_posts, :language_id, :integer
  end

  def self.down
    remove_column :admin_posts, :translated_post_id
    remove_column :admin_posts, :language_id
  end
end
