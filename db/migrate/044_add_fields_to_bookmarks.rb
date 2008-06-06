class AddFieldsToBookmarks < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :notes, :text
    add_column :bookmarks, :private, :boolean
    add_column :bookmarks, :updated_at, :datetime
    remove_column :bookmarks, :title
  end

  def self.down
    add_column :bookmarks, :title, :string, :limit => 50, :default => ""
    remove_column :bookmarks, :updated_at
    remove_column :bookmarks, :private
    remove_column :bookmarks, :notes
  end
end
