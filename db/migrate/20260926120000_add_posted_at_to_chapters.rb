class AddPostedAtToChapters < ActiveRecord::Migration[8.1]
  def up
    add_column :chapters, :posted_at, :datetime
    execute "UPDATE chapters SET posted_at = updated_at WHERE posted = 1"
  end

  def down
    remove_column :chapters, :posted_at
  end
end