class AddArchivistIdToExternalCreatorship < ActiveRecord::Migration
  def self.up
    add_column :external_creatorships, :archivist_id, :integer
  end

  def self.down
    remove_column :external_creatorships, :archivist_id
  end
end
