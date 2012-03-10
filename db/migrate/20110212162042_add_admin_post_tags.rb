class AddAdminPostTags < ActiveRecord::Migration
  def self.up
    create_table :admin_post_tags do |t|
      t.string :name
      t.integer :language_id
      t.timestamps
    end
    create_table :admin_post_taggings do |t|
      t.integer :admin_post_tag_id
      t.integer :admin_post_id
      t.timestamps
    end
  end

  def self.down
    drop_table :admin_post_tags
    drop_table :admin_post_taggings
  end
end
