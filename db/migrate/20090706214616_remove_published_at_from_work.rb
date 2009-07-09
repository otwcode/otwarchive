class RemovePublishedAtFromWork < ActiveRecord::Migration
  def self.up
    remove_column :works, :published_at
  end

  def self.down
    add_column :works, :published_at, :datetime
  end
end
