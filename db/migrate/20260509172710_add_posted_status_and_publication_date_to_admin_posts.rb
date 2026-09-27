class AddPostedStatusAndPublicationDateToAdminPosts < ActiveRecord::Migration[8.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def up
    return if column_exists?(:admin_posts, :posted)

    change_table :admin_posts do |t|
      t.boolean :posted, default: false, null: false
      t.datetime :published_at, default: nil, null: true
    end
    AdminPost.update_all("published_at = created_at, posted = 1")
  end

  def down
    change_table :admin_posts do |t|
      t.remove :posted
      t.remove :published_at
    end
  end
end
