class AddBooleanDefaults < ActiveRecord::Migration
  def self.up
    Bookmark.update_all('hidden_by_admin=0', 'hidden_by_admin IS NULL')
    Chapter.update_all('posted=0', 'posted IS NULL')
    Chapter.update_all('hidden_by_admin=0', 'hidden_by_admin IS NULL')
    Comment.update_all('hidden_by_admin=0', 'hidden_by_admin IS NULL')
    Comment.update_all('is_deleted=0', 'is_deleted IS NULL')
    Comment.update_all('approved=0', 'approved IS NULL')
    ExternalWork.update_all('dead=0', 'dead IS NULL')
    ExternalWork.update_all('hidden_by_admin=0', 'hidden_by_admin IS NULL')
    Preference.update_all('edit_emails_off=0', 'edit_emails_off IS NULL')
    Preference.update_all('comment_emails_off=0', 'comment_emails_off IS NULL')
    Preference.update_all('hide_warnings=0', 'hide_warnings IS NULL')
    Pseud.update_all('is_default=0', 'is_default IS NULL')
    RelatedWork.update_all('reciprocal=0', 'reciprocal IS NULL')
    Series.update_all('hidden_by_admin=0', 'hidden_by_admin IS NULL')
    TagCategory.update_all('required=0', 'required IS NULL')
    TagCategory.update_all('official=0', 'official IS NULL')
    TagCategory.update_all('exclusive=0', 'exclusive IS NULL')
    TagRelationshipKind.update_all('reciprocal=0', 'reciprocal IS NULL')
    Tag.update_all('canonical=0', 'canonical IS NULL')
    Tag.update_all('banned=0', 'banned IS NULL')
    User.update_all('suspended=0', 'suspended IS NULL')
    User.update_all('banned=0', 'banned IS NULL')
    User.update_all('recently_reset=0', 'recently_reset IS NULL')
    Work.update_all('posted=0', 'posted IS NULL')
    Work.update_all('hidden_by_admin=0', 'hidden_by_admin IS NULL')
    
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
