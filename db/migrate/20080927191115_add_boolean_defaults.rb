class AddBooleanDefaults < ActiveRecord::Migration
  def self.up
    change_column :bookmarks, :hidden_by_admin, :boolean, :default => false, :null => false
    change_column :chapters, :posted, :boolean, :default => false, :null => false
    change_column :chapters, :hidden_by_admin, :boolean, :default => false, :null => false
    change_column :comments, :hidden_by_admin, :boolean, :default => false, :null => false  
    change_column :comments, :is_deleted, :boolean, :default => false, :null => false
    change_column :comments, :approved, :boolean, :default => false, :null => false
    change_column :external_works, :dead, :boolean, :default => false, :null => false
    change_column :external_works, :hidden_by_admin, :boolean, :default => false, :null => false
    change_column :preferences, :edit_emails_off, :boolean, :default => false, :null => false
    change_column :preferences, :comment_emails_off, :boolean, :default => false, :null => false
    change_column :preferences, :hide_warnings, :boolean, :default => false, :null => false
    change_column :pseuds, :is_default, :boolean, :default => false, :null => false
    change_column :related_works, :reciprocal, :boolean, :default => false, :null => false
    change_column :series, :hidden_by_admin, :boolean, :default => false, :null => false
    change_column :tag_categories, :required, :boolean, :default => false, :null => false
    change_column :tag_categories, :official, :boolean, :default => false, :null => false
    change_column :tag_categories, :exclusive, :boolean, :default => false, :null => false
    change_column :tag_relationship_kinds, :reciprocal, :boolean, :default => false, :null => false
    change_column :tags, :canonical, :boolean, :default => false, :null => false 
    change_column :tags, :banned, :boolean, :default => false, :null => false
    change_column :users, :suspended, :boolean, :default => false, :null => false
    change_column :users, :banned, :boolean, :default => false, :null => false
    change_column :users, :recently_reset, :boolean, :default => false, :null => false
    change_column :works, :posted, :boolean, :default => false, :null => false
    change_column :works, :hidden_by_admin, :boolean, :default => false, :null => false 
  end

  def self.down
  end
end
