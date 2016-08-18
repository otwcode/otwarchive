class AddUnreviewedToComments < ActiveRecord::Migration
  def change
    add_column :comments, :unreviewed, :boolean, default: false, null: false
  end
end
