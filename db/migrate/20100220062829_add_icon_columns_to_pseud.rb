class AddIconColumnsToPseud < ActiveRecord::Migration
    def self.up
      add_column :pseuds, :icon_file_name,    :string
      add_column :pseuds, :icon_content_type, :string
      add_column :pseuds, :icon_file_size,    :integer
      add_column :pseuds, :icon_updated_at,   :datetime
    end

    def self.down
      remove_column :pseuds, :icon_file_name
      remove_column :pseuds, :icon_content_type
      remove_column :pseuds, :icon_file_size
      remove_column :pseuds, :icon_updated_at
    end

end
