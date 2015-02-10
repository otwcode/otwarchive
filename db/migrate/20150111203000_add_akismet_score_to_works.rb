class AddAkismetScoreToWorks < ActiveRecord::Migration
  def self.up
    add_column :works, :spam, :boolean, default: false, null: false
    add_column :works, :spam_checked_at, :datetime
    add_index "works", "spam"
  end

  def self.down
    remove_index "works", "spam"
    remove_column :works, :spam
    remove_column :works, :spam_checked_at
  end
end
