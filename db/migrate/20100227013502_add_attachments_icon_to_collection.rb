class AddAttachmentsIconToCollection < ActiveRecord::Migration
  def self.up
    add_column :collections, :icon_file_name, :string
    add_column :collections, :icon_content_type, :string
    add_column :collections, :icon_file_size, :integer
    add_column :collections, :icon_updated_at, :datetime
  end

  def self.down
    remove_column :collections, :icon_file_name
    remove_column :collections, :icon_content_type
    remove_column :collections, :icon_file_size
    remove_column :collections, :icon_updated_at
  end
end
