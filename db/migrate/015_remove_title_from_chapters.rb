class RemoveTitleFromChapters < ActiveRecord::Migration
  def self.up
    remove_column :chapters, :title
  end

  def self.down
    add_column :chapters, :title, :string
  end
end
