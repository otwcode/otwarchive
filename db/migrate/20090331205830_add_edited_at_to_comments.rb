class AddEditedAtToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :edited_at, :datetime
  end

  def self.down
    remove_column :comments, :edited_at
  end
end
