class ChangeExternalCreatorship < ActiveRecord::Migration
  def self.up
    add_column :external_creatorships, :external_author_name_id, :integer
    remove_column :external_creatorships, :external_author_id
  end

  def self.down
    add_column :external_creatorships, :external_author_id, :integer
    remove_column :external_creatorships, :external_author_name_id
  end
end
