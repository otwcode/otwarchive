class AddHiddenByAdmin < ActiveRecord::Migration
  def self.up
    add_column :works, :hidden_by_admin, :boolean
    add_column :chapters, :hidden_by_admin, :boolean
    add_column :series, :hidden_by_admin, :boolean
    add_column :comments, :hidden_by_admin, :boolean
    add_column :bookmarks, :hidden_by_admin, :boolean
    add_column :external_works, :hidden_by_admin, :boolean
  end

  def self.down
    remove_column :external_works, :hidden_by_admin
    remove_column :bookmarks, :hidden_by_admin
    remove_column :comments, :hidden_by_admin
    remove_column :series, :hidden_by_admin
    remove_column :chapters, :hidden_by_admin
    remove_column :works, :hidden_by_admin
  end
end
