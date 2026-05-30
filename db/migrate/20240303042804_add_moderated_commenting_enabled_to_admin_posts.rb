class AddModeratedCommentingEnabledToAdminPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :admin_posts, :moderated_commenting_enabled, :boolean, default: false, null: false
  end
end
