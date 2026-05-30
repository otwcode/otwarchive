class AddGuestCommentOffToAdminSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :admin_settings, :guest_comments_off, :boolean, default: false, null: false
  end
end
